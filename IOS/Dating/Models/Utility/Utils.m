//
//  Utils.m
//  Dating
//
//  Created by Harsh Sharma on 7/29/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "Utils.h"

@implementation Utils


+ (id)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end
