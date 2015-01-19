//
//  Message.h
//  STBubbleTableViewCellDemo
//
//  Created by Cedric Vandendriessche on 24/08/13.
//  Copyright 2013 FreshCreations. All rights reserved.
//

#pragma mark Message_Keys

#define msg_Date          @"dt"
#define msg_ID            @"mid"
#define msg_text          @"msg"
#define msg_Reciver_ID    @"rfid"
#define msg_Sender_ID     @"sfid"
#define msg_Sender_Name   @"sname"
#define msg_Media         @"media_file"
#define msg_Media_URL     @"msgfile"
#define msg_Media_Section @"msgtype"

#import <Foundation/Foundation.h>

@interface Message : NSObject

+ (instancetype)messageWithDictionary:(NSDictionary *)messageDict;
+ (instancetype)messageWithDictionary:(NSDictionary *)messageDict image:(UIImage *)image;

- (instancetype)initWithDictionary:(NSDictionary *)messageDict;
- (instancetype)initWithDictionary:(NSDictionary *)messageDict image:(UIImage *)image;

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *attachmentURL;
@property (strong, nonatomic) NSData *attachmentData;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *messageSenderID;
@property (nonatomic, strong) NSString *messageReciverID;
@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *messageSenderName;
@property (nonatomic, strong) NSString *messageDate;
@property (assign, nonatomic) BOOL isMySentMessage;
@property (assign, nonatomic) AttachmentType attachmentType;

@end
