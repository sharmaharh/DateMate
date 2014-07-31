//
//  Utils.h
//  Dating
//
//  Created by Harsh Sharma on 7/29/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject


/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Void
 Functionality : To Create a Singelton Object of Utils, which will be alive throughout the run of the app.
 
 ------------------------------------------------------*/

+ (Utils *)sharedInstance;

@end
