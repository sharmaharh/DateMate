//
//  MyWebSocket.h
//  NaveenChatApp
//
//  Created by Techahead on 10/06/14.
//  Copyright (c) 2013 Techahead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebSocket.h"

//=========Headers of Bytes==============
#define kIsGroupChat @"isGroupChat"
#define kFromId @"fromId"
#define kToId @"toId"
#define kChatId @"chatId"
#define kDeviceTimeStamp @"deviceTimeStamp"
#define kServerTimeStamp @"serverTimeStamp"
#define kTextByte @"textByte"
#define kImageByte @"imageByte"
#define kVideoByte @"videoByte"
#define kAttachmentType @"attachmentType"
#define kText @"text"
#define kImage @"image"
#define kVideo @"video"
#define kAttachment @"attachment"
//=========================================

@protocol MyWebSocketDelegate <NSObject>

@optional
- (void)didReceiveDataFromOpponent:(NSMutableDictionary *)data;
- (void)didReceiveTextFromOpponent:(NSString *)message;
@end

@interface MyWebSocket : NSObject <WebSocketDelegate>
{

}

@property (nonatomic, retain) WebSocket* webSocket;
@property(nonatomic, strong) id<MyWebSocketDelegate> webSocketDelegate;

+ (MyWebSocket *)sharedInstance;
- (void)connectSocketWithBlock:(void(^)(BOOL connected,NSError *error))block;
- (void)sendData:(NSData *)data acknowledge:(void(^)(NSData *data, NSError *error))block;
- (void)sendDictionary:(NSDictionary *)dict acknowledge:(void(^)(NSString *data, NSError *error))block;
- (void)sendText:(NSString *)message acknowledge:(void(^)(NSString *message, NSError *error))block;

@end
