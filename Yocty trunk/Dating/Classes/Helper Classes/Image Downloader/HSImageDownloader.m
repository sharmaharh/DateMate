//
//  HSImageDownloader.m
//  Dating
//
//  Created by Harsh Sharma on 1/17/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import "HSImageDownloader.h"

typedef void(^ImageDownlodedBlock)(UIImage *image, NSString *imgURL ,NSError *error);

@implementation HSImageDownloader

+ (id)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self.imageQueueDict = [NSMutableDictionary dictionary];
    return self;
}

- (void)imageWithImageURL:(NSString *)imgURL withFBID:(NSString *)fbID withImageDownloadedBlock:(void(^)(UIImage *image, NSString *imgURL ,NSError *error))block
{

    if (!imgURL || !imgURL.length) {
        return;
    }
    __block NSString *bigImageURLString = imgURL;
    
    NSString *dirPath = @"";
    if (fbID)
    {
        dirPath = [FileManager ProfileImageFolderPathWithFBID:fbID];
    }
    else
    {
        dirPath = [FileManager SplashImageFolderPath];
    }
    
    NSString *filePath = [dirPath stringByAppendingPathComponent:[imgURL lastPathComponent]];
    
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (image)
        {
            block(image, imgURL, nil);
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [self imageWithImageURL:imgURL withFBID:fbID withImageDownloadedBlock:block];
        }
        
    }
    else
    {
        NSMutableArray *blocksArray = nil;
        
        if (![[self.imageQueueDict allKeys] containsObject:imgURL])
        {
            blocksArray = [NSMutableArray arrayWithObject:block];
            [self.imageQueueDict setObject:blocksArray forKey:imgURL];
        }
        else
        {
            blocksArray = self.imageQueueDict[imgURL];
            [blocksArray addObject:block];
            [self.imageQueueDict setObject:blocksArray forKey:imgURL];
            return;
        }
        
        
        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
            
            
            __block NSData *imageData = nil;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error)
             {
                 
                 NSMutableArray *callingsArray = [self.imageQueueDict objectForKey:res.URL.absoluteString];
                 
                 if (!error)
                 {
                     imageData = data;
                     UIImage *image = nil;
                     data = nil;
                     image = [UIImage imageWithData:imageData];
                     
                     if (image == nil)
                     {
                         image = [UIImage imageNamed:@"Bubble-0"];
                     }
                     
                     if ([res.URL.absoluteString length])
                     {
                         [self.imageQueueDict removeObjectForKey:res.URL.absoluteString];
                     }
                     
                     
                     for (ImageDownlodedBlock block in callingsArray)
                     {
                         ImageDownlodedBlock returnBlock = block;
                         returnBlock(image, res.URL.absoluteString, nil);
                     }
                     
                     // Write Image in Document Directory
                     int64_t delayInSeconds = 0.4;
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                     
                     
                     dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
                         if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                         {
                             if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
                             {
                                 [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
                             }
                             
                             [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
                             
                         }
                         imageData = nil;
                     });
                 }
                 else
                 {
                     [self.imageQueueDict removeObjectForKey:res.URL.absoluteString];
                     for (ImageDownlodedBlock block in callingsArray)
                     {
                         block(nil, nil, error);
                     }
                 }
                 
             }];
            
            bigImageURLString = nil;
            
        });
    }

}

@end
