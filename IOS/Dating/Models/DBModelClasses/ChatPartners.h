//
//  ChatPartners.h
//  Dating
//
//  Created by Harsh Sharma on 9/18/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatPartners : NSManagedObject

@property (nonatomic, retain) NSString * fbId;
@property (nonatomic, retain) NSString * fName;
@property (nonatomic, retain) NSString * pPic_local;
@property (nonatomic, retain) NSString * pPic_remote;
@property (nonatomic, retain) NSNumber * unreadCount;
@property (nonatomic, retain) NSString * ladt;

@end
