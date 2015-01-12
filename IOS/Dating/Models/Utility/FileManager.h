//
//  FileManager.h
//  Dating
//
//  Created by Harsh Sharma on 1/9/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Class Type (Instance Type)
 Functionality : To Create a Singelton Object of Utils, which will be alive throughout the run of the app.
 
 ------------------------------------------------------*/

+ (FileManager *)sharedInstance;


+ (NSString *)ProfileImageFolderPathWithFBID:(NSString *)fbID;

@end
