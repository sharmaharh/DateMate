//
//  ChatPartners.h
//  Dating
//
//  Created by Harsh Sharma on 10/15/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatPartners : NSManagedObject

@property (nonatomic, retain) NSNumber * chatCategory;
@property (nonatomic, retain) NSNumber * chatStatus;
@property (nonatomic, retain) NSString * fbId;
@property (nonatomic, retain) NSString * fName;
@property (nonatomic, retain) NSString * ladt;
@property (nonatomic, retain) NSString * pPic_local;
@property (nonatomic, retain) NSString * pPic_remote;
@property (nonatomic, retain) NSNumber * totalChatCount;
@property (nonatomic, retain) NSNumber * unreadCount;
@property (nonatomic, retain) NSNumber * chatFlagInitiate;

@end
