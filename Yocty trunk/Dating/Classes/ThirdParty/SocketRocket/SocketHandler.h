//
//  SocketHandler.h
//  Dating
//
//  Created by Harsh Sharma on 2/7/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface SocketHandler : NSObject <SRWebSocketDelegate>

@property (strong, nonatomic) SRWebSocket *webSocket;

- (void)logOutUser;

@end
