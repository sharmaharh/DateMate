//
//  HSImageDownloader.h
//  Dating
//
//  Created by Harsh Sharma on 1/17/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface HSImageDownloader : NSObject

@property (retain, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSMutableDictionary *imageQueueDict;

+ (id)sharedInstance;
- (void)imageWithImageURL:(NSString *)imgURL withFBID:(NSString *)fbID withImageDownloadedBlock:(void(^)(UIImage *image, NSString *imgURL ,NSError *error))block;

@end
