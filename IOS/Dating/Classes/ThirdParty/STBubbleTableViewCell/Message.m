//
//  Message.m
//  STBubbleTableViewCellDemo
//
//  Created by Cedric Vandendriessche on 24/08/13.
//  Copyright 2013 FreshCreations. All rights reserved.
//

#import "Message.h"

@implementation Message

+ (instancetype)messageWithDictionary:(NSDictionary *)messageDict
{
    return [Message messageWithDictionary:messageDict image:nil];
}

+ (instancetype)messageWithDictionary:(NSDictionary *)messageDict image:(UIImage *)image
{
    return [[Message alloc] initWithDictionary:messageDict image:image];
}

- (instancetype)initWithDictionary:(NSDictionary *)messageDict
{
	return [self initWithDictionary:messageDict image:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)messageDict image:(UIImage *)image
{
	self = [super init];
	if(self)
	{
		_avatar = image;
        
        _message           = messageDict[msg_text];
        _messageID         = messageDict[msg_ID];
        _messageDate       = messageDict[msg_Date];
        _messageSenderID   = messageDict[msg_Sender_ID];
        _messageReciverID  = messageDict[msg_Reciver_ID];
        _messageSenderName = messageDict[msg_Sender_Name];
		
        _isMySentMessage = [messageDict[msg_Sender_ID] isEqualToString:[FacebookUtility sharedObject].fbID];
	}
	return self;
}

@end
