//
//  ChatAttachmentHelperClass.m
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "ChatAttachmentHelperClass.h"
#import "ChatViewController.h"

@implementation ChatAttachmentHelperClass
{
    
}

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

- (void)playAudioWithURLString:(NSString *)audioStrURL
{
    if (self.audioPlayer.rate)
    {
        [self.audioPlayer pause];
    }
    
    self.audioPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:audioStrURL]];
    [self.audioPlayer play];
}

- (void)startAudioRecording
{
    NSString *filePath = [[self AttachmentsFolderPath] stringByAppendingPathComponent:@"temp.caf"];
    self.audioRecorder = nil;
    _audioRecordingTimer = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:44100],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                                   [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
    NSError *recordingError;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[[self AttachmentsFolderPath] stringByAppendingPathComponent:@"temp.caf"]] settings:audioSettings error:&recordingError];

    [self.audioRecorder updateMeters];
    //prepare to record
    [self.audioRecorder setDelegate:self];
    [self.audioRecorder prepareToRecord];
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder recordForDuration:10.0f];
    
    _audioRecordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                  target:self.audioRecordingView
                                                selector:@selector(updateRecordingProgress)
                                                userInfo:nil
                                                 repeats:YES];
}

- (NSString *)AttachmentsFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Attachments"];
    basePath = [basePath stringByAppendingPathComponent:[FacebookUtility sharedObject].fbID];
    return basePath;
}

#pragma mark ----
#pragma mark UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    ChatViewController *chatViewController = (ChatViewController *)self.attchmentDelegate;
    
    if ([self.imagePickerController.mediaTypes isEqual:@[(NSString *)kUTTypeImage]])
    {
        // Image
        chatViewController.attachmentType = kImage;
        self.attachmentURL = [info[UIImagePickerControllerReferenceURL] absoluteString];
        self.attachmentData = UIImagePNGRepresentation(info[UIImagePickerControllerEditedImage]);
    }
    else
    {
        // Video
        chatViewController.attachmentType = KVideo;
        self.attachmentURL = [info[UIImagePickerControllerMediaURL] absoluteString];
        self.attachmentData = [NSData dataWithContentsOfURL:(info[UIImagePickerControllerMediaURL])];
    }
        
    [chatViewController dismissViewControllerAnimated:YES completion:nil];
    [chatViewController btnSendMessagePressed:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [(UIViewController *)self.attchmentDelegate dismissViewControllerAnimated:YES completion:nil];
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
    [self.audioRecordingView.btn1 setSelected:NO];
    [self.audioRecordingView.btn2 setSelected:YES];
    [self.audioRecordingTimer invalidate];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    [self.audioRecordingView.btn1 setSelected:NO];
    [self.audioRecordingView.btn2 setSelected:NO];
    [self.audioRecordingView.recorderProgressView setProgress:0];
    [self.audioRecordingTimer invalidate];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [self.audioRecordingView.btn1 setSelected:NO];
    [self.audioRecordingView.btn2 setSelected:NO];
    [self.audioRecordingView.recorderProgressView setProgress:0];
    [self.audioRecordingTimer invalidate];
}


@end
