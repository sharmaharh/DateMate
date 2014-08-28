//
//  Message.h
//  STBubbleTableViewCellDemo
//
//  Created by Cedric Vandendriessche on 24/08/13.
//  Copyright 2013 FreshCreations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

+ (instancetype)messageWithString:(NSString *)message isMySentMessage:(BOOL)isMySentMessage;
+ (instancetype)messageWithString:(NSString *)message image:(UIImage *)image isMySentMessage:(BOOL)isMySentMessage;

- (instancetype)initWithString:(NSString *)message isMySentMessage:(BOOL)isMySentMessage;
- (instancetype)initWithString:(NSString *)message image:(UIImage *)image isMySentMessage:(BOOL)isMySentMessage;

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIImage *avatar;
@property (assign, nonatomic) BOOL isMySentMessage;
@end
