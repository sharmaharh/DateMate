//
//  ChatHistory.h
//  Dating
//
//  Created by Harsh Sharma on 18/09/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatHistory : NSManagedObject

@property (nonatomic, retain) NSString * dt;
@property (nonatomic, retain) NSString * mid;
@property (nonatomic, retain) NSString * msg;
@property (nonatomic, retain) NSString * rfid;
@property (nonatomic, retain) NSString * sfid;
@property (nonatomic, retain) NSString * sname;

@end
