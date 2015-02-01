//
//  MyWebSocket.m
//  NaveenChatApp
//
//  Created by Techahead on 10/06/14.
//  Copyright (c) 2013 Techahead. All rights reserved.
//


#import "MyWebSocket.h"
#import "ChatViewController.h"

typedef void(^Connect)(BOOL connected,NSError *error);
typedef void(^SendData)(NSData *data, NSError *error);
typedef void(^SendText)(NSString *message, NSError *error);
typedef void(^Acknowledgement)(NSString *ack, NSError *error);


@interface MyWebSocket ()

@property(nonatomic,copy) Connect connectBlock;
@property(nonatomic,copy) SendData sendDataBlock;
@property(nonatomic,copy) SendText sendTextBlock;
@property(nonatomic,copy) Acknowledgement acknowledgementBlock;

@end

@implementation MyWebSocket

+ (MyWebSocket *)sharedInstance
{
    static MyWebSocket *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MyWebSocket alloc] init];
    });
    
    return _sharedInstance;
}


#pragma mark Lifecycle

- (void)initializeSocket
{
    //make sure to use the right url, it must point to your specific web socket endpoint or the handshake will fail
    //create a connect config and set all our info here
    NSString *userId = [FacebookUtility sharedObject].fbID;//[[NSUserDefaults standardUserDefaults] objectForKey:kuserId];
    NSString *socketUrl=[NSString stringWithFormat:@"ws://incredtechnolgies.com:18000"];
   // NSString *socketUrl=[NSString stringWithFormat:@"ws://10.11.5.99/linkmess/api/Chat/Get?userid=%@",userId];
    //staging10.techaheadcorp.com/linkmessenger/api/Chat/Get?userid
    //10.11.5.99/linkmess/api/service/api/Chat/Get?userid
    
    WebSocketConnectConfig* config = [WebSocketConnectConfig configWithURLString:socketUrl origin:nil protocols:nil tlsSettings:nil headers:nil verifySecurityKey:YES extensions:nil ];
    config.closeTimeout = 60.0;
    config.keepAlive = 100000000.0; //sends a webSocket ping every 15s to keep socket alive
    
    //setup dispatch queue for delegate logic (not required, the websocket will create its own if not supplied)
    dispatch_queue_t delegateQueue = dispatch_queue_create("myWebSocketQueue", NULL);
    
    //open using the connect config, it will be populated with server info, such as selected protocol/etc
    self.webSocket = [WebSocket webSocketWithConfig:config queue:delegateQueue delegate:self];
}

- (NSDictionary *)convertToDictionaryFromBytes:(NSData *)data
{
    return nil;
}

- (void)connectSocketWithBlock:(void(^)(BOOL connected,NSError *error))block
{
    self.connectBlock = block;
    self.webSocket = nil;
    
    [self initializeSocket];
    [self.webSocket open];
}

- (void)sendData:(NSData *)data acknowledge:(void(^)(NSData *data, NSError *error))block
{
    self.sendDataBlock = block;
    [self.webSocket sendBinary:data];
}


- (void)sendDictionary:(NSDictionary *)dict acknowledge:(void(^)(NSString *ack, NSError *error))block
{
    self.acknowledgementBlock = block;
    
//    NSMutableData *data = [NSMutableData data];
//    
//    NSString *isGroupChatString = [dict objectForKey:kIsGroupChat];
//    long long int isGroupChat = [isGroupChatString longLongValue];
//    
//    NSString *fromidString = SharedAppDelegate.UserId;//[[NSUserDefaults standardUserDefaults] objectForKey:kuserId];
//    long long int fromid = [fromidString longLongValue];
//    
//    NSString *toidString = [dict objectForKey:kToId];
//    long long int toid = [toidString longLongValue];
//    
//    NSString *chatIdString = [dict objectForKey:kChatId];
//    long long int chatid = [chatIdString longLongValue];
//    
//    long long int deviceTimeStamp = (long long int)[[NSDate date] timeIntervalSince1970];
//    
//    NSString *message = [dict objectForKey:kText];
//    NSData *textData = [message dataUsingEncoding:NSUTF8StringEncoding];
//    long long int textBytes = [textData length];
//    
//    UIImage *cameraCapturedImage = [dict objectForKey:kImage];
//    NSData *imageData = UIImagePNGRepresentation(cameraCapturedImage);
//    long long int imageBytes = [imageData length];
//    
//    NSData *videoData = [dict objectForKey:kVideo];
//    unsigned long long int videoBytes = [videoData length];
//    
//    [data appendBytes:&isGroupChat length:8];
//    [data appendBytes:&fromid length:8];
//    [data appendBytes:&toid length:8];
//    [data appendBytes:&chatid length:8];
//    [data appendBytes:&deviceTimeStamp length:8];
//    [data appendBytes:&textBytes length:8];
//    [data appendBytes:&imageBytes length:8];
//    [data appendBytes:&videoBytes length:8];
//    [data appendData:textData];
//    [data appendData:imageData];    [data appendData:videoData];
//    
//        
//    
//    [self.webSocket sendBinary:data];
}

- (void)sendText:(NSString *)message acknowledge:(void(^)(NSString *message, NSError *error))block
{
    self.sendTextBlock = block;
    [self.webSocket sendText:message];
}

#pragma mark Web Socket
/**
 * Called when the web socket connects and is ready for reading and writing.
 **/
- (void) didOpen
{
    NSLog(@"Socket is open for business.");
    if (self.connectBlock)
    {
        self.connectBlock(YES,nil);
        self.connectBlock = nil;
    }
}

/**
 * Called when the web socket closes. aError will be nil if it closes cleanly.
 **/
- (void) didClose:(NSUInteger) aStatusCode message:(NSString*) aMessage error:(NSError*) aError
{
    NSLog(@"Oops. It closed.");
    if (self.connectBlock)
    {
        self.connectBlock(NO,aError);
        self.connectBlock = nil;
    }
    
    self.acknowledgementBlock = nil;
}

/**
 * Called when the web socket receives an error. Such an error can result in the
 socket being closed.
 **/
- (void) didReceiveError:(NSError*) aError
{
    NSLog(@"Oops. An error occurred.");
    if (self.connectBlock)
    {
        self.connectBlock(NO,aError);
        self.connectBlock = nil;
    }
    
    self.acknowledgementBlock = nil;
}

/**
 * Called when the web socket receives a message.
 **/
- (void) didReceiveTextMessage:(NSString*) aMessage
{
    //Hooray! I got a message to print.
    NSLog(@"didReceiveTextMessage");
    if (self.acknowledgementBlock)
    {
        self.acknowledgementBlock(aMessage,nil);
        self.acknowledgementBlock = nil;
    }

}

/**
 * Called when the web socket receives a message.
 **/
- (void)didReceiveBinaryMessage:(NSData*)aMessage
{

    NSData *receivedData = [[NSMutableData alloc] initWithData:aMessage];
    //Hooray! I got a binary message.
    
    NSMutableDictionary *dictMessage = [NSMutableDictionary dictionary];
    
    long long int isGroupChat;
    
    NSData *data1 = [receivedData subdataWithRange:NSMakeRange(0, 8)];
    [data1 getBytes:&isGroupChat length:8];
    NSString *isGroupChatString=[NSString stringWithFormat:@"%lu",(unsigned long)isGroupChat];
    [dictMessage setObject:isGroupChatString forKey:kIsGroupChat];
    
    
    long long int fromUserId;
    NSData *data2 = [receivedData subdataWithRange:NSMakeRange(8, 8)];
    [data2 getBytes:&fromUserId length:8];
    NSString *fromUserIdString=[NSString stringWithFormat:@"%lu",(unsigned long)fromUserId];
    [dictMessage setObject:fromUserIdString forKey:kFromId];
    
    
    long long int toUserId;
    NSData *data3 = [receivedData subdataWithRange:NSMakeRange(16, 8)];
    [data3 getBytes:&toUserId length:8];
    NSString *toUserIdString =[NSString stringWithFormat:@"%lu",(unsigned long)toUserId];
    [dictMessage setObject:toUserIdString forKey:kToId];
    
    
    long long int chatId;
    NSData *data4 = [receivedData subdataWithRange:NSMakeRange(24, 8)];
    [data4 getBytes:&chatId length:8];
    NSString *chatIdString =[NSString stringWithFormat:@"%lu",(unsigned long)chatId];
    [dictMessage setObject:chatIdString forKey:kChatId];
    
    long long int deviceTimeStamp;
    NSData *data5 = [receivedData subdataWithRange:NSMakeRange(32, 8)];
    [data5 getBytes:&deviceTimeStamp length:8];
    NSString *deviceTimeStampString =[NSString stringWithFormat:@"%lu",(unsigned long)deviceTimeStamp];
    [dictMessage setObject:deviceTimeStampString forKey:kDeviceTimeStamp];
    
    long long int serverTimeStamp;
    NSData *data51 = [receivedData subdataWithRange:NSMakeRange(40, 8)];
    [data51 getBytes:&serverTimeStamp length:8];
    NSString *serverTimeStampString =[NSString stringWithFormat:@"%lu",(unsigned long)serverTimeStamp];
    [dictMessage setObject:serverTimeStampString forKey:kServerTimeStamp];
    
    
    long long int textBytes;
    NSData *data6 = [receivedData subdataWithRange:NSMakeRange(48, 8)];
    [data6 getBytes:&textBytes length:8];
    
    
    long long int imageBytes;
    NSData *data7 = [receivedData subdataWithRange:NSMakeRange(56, 8)];
    [data7 getBytes:&imageBytes length:8];
    
    
    long long int videoBytes;
    NSData *data8 = [receivedData subdataWithRange:NSMakeRange(64, 8)];
    [data8 getBytes:&videoBytes length:8];
    
    long long int attachmentType;
    NSData *data9 = [receivedData subdataWithRange:NSMakeRange(72, 8)];
    [data9 getBytes:&attachmentType length:8];
    NSString *attachmentTypeString =[NSString stringWithFormat:@"%lu",(unsigned long)attachmentType];
    [dictMessage setObject:attachmentTypeString forKey:kAttachmentType];
    
    NSData *data10 = [receivedData subdataWithRange:NSMakeRange(80, (NSUInteger)textBytes)];
    NSString *textMsg = [[NSString alloc] initWithData:data10 encoding:NSUTF8StringEncoding];
    if (textMsg) {
        [dictMessage setObject:textMsg forKey:kText];
    }
    
    NSUInteger dataOffset = (NSUInteger)(80+textBytes);
    
    NSData *data11 = [receivedData subdataWithRange:NSMakeRange(dataOffset, (NSUInteger)imageBytes)];
    UIImage *image = [UIImage imageWithData:data11];
    if (image)
    {
        NSString *imagePath = [MyWebSocket pathToWriteImageInDocumentsDirectory:data11 WithServerTimeStampString:serverTimeStampString];
        [dictMessage setObject:imagePath forKey:kImage];
    }
    
    dataOffset = (NSUInteger)(dataOffset+imageBytes);
    
    NSData *data12 = [receivedData subdataWithRange:NSMakeRange(dataOffset, (NSUInteger)videoBytes)];
    if (data12.length > 0) {
        [dictMessage setObject:data12 forKey:kVideo];
    }
    
    dataOffset = (NSUInteger)(dataOffset+videoBytes);
    
    NSUInteger attachmentLength = receivedData.length- dataOffset;
    
    NSData *data13 = [receivedData subdataWithRange:NSMakeRange(dataOffset, attachmentLength)];
    if (data13.length > 0) {
        [dictMessage setObject:data13 forKey:kAttachment];
    }
    
    
    if (self.webSocketDelegate && [self.webSocketDelegate respondsToSelector:@selector(didReceiveDataFromOpponent:)])
    {
        [self.webSocketDelegate didReceiveDataFromOpponent:dictMessage];
    }
}

+ (NSString *)pathToWriteImageInDocumentsDirectory:(NSData *)imageData WithServerTimeStampString:(NSString *)serverTimeStamp
{
    NSString *filePath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    filePath = [filePath stringByAppendingPathComponent:@"LMImages"];
    // Check the Directory exits or need to create again
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *imagePath = [filePath stringByAppendingPathComponent:[serverTimeStamp stringByAppendingString:@"_image.png"]];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    return imagePath;
}

/**
 * Called when pong is sent... For keep-alive optimization.
 **/
- (void) didSendPong:(NSData*) aMessage
{
    NSLog(@"Yay! Pong was sent!");
}

@end
