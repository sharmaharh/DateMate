//
//  FileManager.m
//  Dating
//
//  Created by Harsh Sharma on 1/9/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

+ (id)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)ProfileImageFolderPathWithFBID:(NSString *)fbID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Profile_Images"];
    basePath = [basePath stringByAppendingPathComponent:fbID];
    return basePath;
}

@end
