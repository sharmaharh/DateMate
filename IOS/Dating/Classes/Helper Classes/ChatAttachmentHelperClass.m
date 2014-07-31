//
//  ChatAttachmentHelperClass.m
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "ChatAttachmentHelperClass.h"

@implementation ChatAttachmentHelperClass

+ (id)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)openImagePickerControllerForImageForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (!self.imagePickerController)
    {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
    }
    
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        self.imagePickerController.sourceType = sourceType;
    }
    
    else
    {
        // Show OK Alert
    }
    
    [(UIViewController *)self.attchmentDelegate presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)openImagePickerControllerForVideo
{
    if (!self.imagePickerController)
    {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
    }
    
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    else
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [(UIViewController *)self.attchmentDelegate presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)startAudioRecording
{
    self.audioRecorder = [[AVAudioRecorder alloc] init];
    self.audioRecorder.delegate = self;
    [self.audioRecorder recordForDuration:120];
    [self.audioRecorder record];
}


#pragma mark ----
#pragma mark UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}



#pragma mark ----
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
}



#pragma mark ----
#pragma mark AVAudioRecorderDelegate



- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    
}


@end
