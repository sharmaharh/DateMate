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
typedef void(^SendData)(NSDictionary *data, NSError *error);
typedef void(^SendText)(NSDictionary *messageDict, NSError *error);
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
    NSString *socketUrl= @"ws://69.195.70.43:18000/chat";

    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:socketUrl]]];
    _webSocket.delegate = self;
    [_webSocket setDelegateDispatchQueue:dispatch_queue_create("myWebSocketQueue", NULL)];

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


- (void)sendDictionary:(NSDictionary *)dict acknowledge:(void(^)(NSString *ack, NSError *error))block
{
    self.acknowledgementBlock = block;
    
    [self.webSocket send:dict];

}

- (void)sendText:(NSDictionary *)messageDict acknowledge:(void(^)(NSDictionary *message, NSError *error))block
{
    if (!self.sendTextBlock)
    {
        self.sendTextBlock = block;
    }

    NSLog(@"Send Message Text = %@",messageDict);
    [self.webSocket send:messageDict];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    NSLog(@"Socket is open for business.");
    
//    [self sendText:@{@"type" : @"login", @"userId" : [FacebookUtility sharedObject].fbID} acknowledge:^(NSDictionary *messageDict, NSError *error)
//     {
//         NSLog(@"Login Response = %@",messageDict);
//         
//     }];
    
    if (self.connectBlock)
    {
        self.connectBlock(YES,nil);
        self.connectBlock = nil;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"Oops. An error occurred.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utils showOKAlertWithTitle:[NSString stringWithFormat:@"Error = %@",[error localizedDescription]] message:[error localizedDescription]];
    });
    if (self.connectBlock)
    {
        
        self.connectBlock(NO,error);
        self.connectBlock = nil;
    }
    
    self.acknowledgementBlock = nil;
    self.webSocket.delegate = nil;
    self.webSocket = nil;
}

/**
 * Called when the web socket receives a message.
 **/

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)messageDict;
{
    
//    NSMutableDictionary *dict = [self convertJSONStringToNSDictionary:messageDict];
    NSLog(@"didReceiveTextMessage = %@",messageDict);
    self.sendTextBlock(messageDict,nil);
    
    //    [_messages addObject:[[TCMessage alloc] initWithMessage:message[@"body"][@"chat"][@"msg"] fromMe:NO]];
    //    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //    [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User" message:@"Connection Closed! (see logs)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    });
    self.webSocket.delegate = nil;
    self.webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Websocket received pong");
}

- (NSMutableDictionary *)convertJSONStringToNSDictionary:(NSString *)strJSON
{
    NSData *messageData = [strJSON dataUsingEncoding:NSUTF8StringEncoding];;
    
    NSMutableDictionary *dict = [[NSJSONSerialization JSONObjectWithData:messageData options:NSJSONReadingAllowFragments error:nil] mutableCopy];
    
    if ([[dict allKeys] containsObject:@"body"])
    {
        if([[dict objectForKey:@"body"] isKindOfClass:[NSString class]])
        {
            NSDictionary *dict2 = [self convertJSONStringToNSDictionary:[dict objectForKey:@"body"]];
            if (dict2)
            {
                [dict setObject:dict2 forKey:@"body"];
            }
            
        }
    }
    return dict;
}


- (void)attachment:(NSMutableDictionary *)dictMessage data13:(NSData *)data13 serverTimeStampString:(NSString *)serverTimeStampString attachmentType:(long long int)attachmentType
{
    switch (attachmentType)
    {
        case 1:
        {
            // Image
            NSString *imagePath = [MyWebSocket pathToWriteFileInDocumentsDirectory:data13 inSubDirectoryName:@"Attachments" WithServerTimeStampString:serverTimeStampString withSuffixName:@"_image.png"];
            [dictMessage setObject:imagePath forKey:kAttachment];
        }
            break;
            
        case 2:
        {
            // Video
            NSString *videoPath = [MyWebSocket pathToWriteFileInDocumentsDirectory:data13 inSubDirectoryName:@"Attachments" WithServerTimeStampString:serverTimeStampString withSuffixName:@"_video.mov"];
            [dictMessage setObject:videoPath forKey:kAttachment];
        }
            break;
            
        case 3:
        {
            // Audio
            NSString *audioPath = [MyWebSocket pathToWriteFileInDocumentsDirectory:data13 inSubDirectoryName:@"Attachments" WithServerTimeStampString:serverTimeStampString withSuffixName:@"_audio.caf"];
            [dictMessage setObject:audioPath forKey:kAttachment];
        }
            break;
            
        case 4:
        {
            // Location
            NSString *locationPath = [[NSString alloc] initWithData:data13 encoding:NSUTF8StringEncoding];
            [dictMessage setObject:locationPath forKey:kAttachment];
        }
            
            break;
            
        case 5:
            // Contact
            //                NSString *locationPath = [[NSString alloc] initWithData:data13 encoding:NSUTF8StringEncoding];
            //                [dictMessage setObject:locationPath forKey:kAttachment];
            break;
            
        default:
            break;
    }
}


+ (NSString *)pathToWriteFileInDocumentsDirectory:(NSData *)Data inSubDirectoryName:(NSString*)subDirName WithServerTimeStampString:(NSString *)serverTimeStamp withSuffixName:(NSString *)suffixString
{
    NSString *dirPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    dirPath = [dirPath stringByAppendingPathComponent:subDirName];
    // Check the Directory exits or need to create again
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *filePath = [dirPath stringByAppendingPathComponent:[serverTimeStamp stringByAppendingString:suffixString]];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:Data attributes:nil];
    return filePath;
}

- (void)logOutUserShouldClose:(BOOL)shouldClose
{
    if (self.webSocket.readyState == SR_OPEN || self.webSocket.readyState == SR_CONNECTING || self.webSocket.readyState == SR_CLOSING)
    {
        [self sendText:@{@"type" : @"logout"} acknowledge:^(NSDictionary *message, NSError *error) {
            NSLog(@"User is logged out");
            if (shouldClose)
            {
                [self.webSocket close];
            }
            
        }];
        
    }
    
}

@end
