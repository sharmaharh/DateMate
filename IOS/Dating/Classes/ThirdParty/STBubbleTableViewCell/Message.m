//
//  Message.m
//  STBubbleTableViewCellDemo
//
//  Created by Cedric Vandendriessche on 24/08/13.
//  Copyright 2013 FreshCreations. All rights reserved.
//

#import "Message.h"

@implementation Message

+ (instancetype)messageWithString:(NSString *)message isMySentMessage:(BOOL)isMySentMessage
{
	return [Message messageWithString:message image:nil  isMySentMessage:(BOOL)isMySentMessage];
}

+ (instancetype)messageWithString:(NSString *)message image:(UIImage *)image isMySentMessage:(BOOL)isMySentMessage
{
	return [[Message alloc] initWithString:message image:image  isMySentMessage:(BOOL)isMySentMessage];
}

- (instancetype)initWithString:(NSString *)message  isMySentMessage:(BOOL)isMySentMessage
{
	return [self initWithString:message image:nil isMySentMessage:(BOOL)isMySentMessage];
}

- (instancetype)initWithString:(NSString *)message image:(UIImage *)image isMySentMessage:(BOOL)isMySentMessage
{
	self = [super init];
	if(self)
	{
		_message = message;
		_avatar = image;
        _isMySentMessage = isMySentMessage;
	}
	return self;
}

@end
