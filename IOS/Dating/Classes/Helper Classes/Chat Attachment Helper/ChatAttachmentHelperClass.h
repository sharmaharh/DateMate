//
//  ChatAttachmentHelperClass.h
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioRecordingView.h"

@protocol AttachmentHelperDelegate <NSObject>


@end

typedef enum : int {
    kText = 1,
    kImage,
    KVideo,
    kAudio,
} AttachmentType;


@interface ChatAttachmentHelperClass : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate>


@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) NSData *attachmentData;
@property (strong, nonatomic) NSString *attachmentURL;
@property (strong, nonatomic) AudioRecordingView *audioRecordingView;
@property (strong, nonatomic) NSTimer *audioRecordingTimer;
@property (strong, nonatomic) id <AttachmentHelperDelegate> attchmentDelegate;

/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Void
 Description : To Create a Singelton Object of ChatAttachmentHelperClass, which will be alive throughout the run of the app.
 
 ------------------------------------------------------*/

+ (ChatAttachmentHelperClass *)sharedInstance;

- (void)openImagePickerControllerForImageForSourceType:(UIImagePickerControllerSourceType)sourceType;

- (void)openImagePickerControllerForVideo;

- (void)startAudioRecording;

- (void)playAudioWithURLString:(NSString *)audioStrURL;

@end
