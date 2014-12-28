//
//  AudioRecordingView.m
//  Dating
//
//  Created by Harsh Sharma on 11/7/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "AudioRecordingView.h"
#import "ChatAttachmentHelperClass.h"

@implementation AudioRecordingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = (AudioRecordingView *)[[NSBundle mainBundle] loadNibNamed:@"AudioRecordingView" owner:self options:nil][0];
        [ChatAttachmentHelperClass sharedInstance].audioRecordingView = self;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)btnSendAudioPressed:(id)sender
{
    UIButton *btn2 = (UIButton *)sender;
    btn2.selected = !btn2.selected;
    ChatViewController *chatViewController = (ChatViewController *)[ChatAttachmentHelperClass sharedInstance].attchmentDelegate;
    
    if (!btn2.selected)
    {
        // Send Audio Recording
        chatViewController.attachmentType = kAudio;
        [ChatAttachmentHelperClass sharedInstance].attachmentURL = [[ChatAttachmentHelperClass sharedInstance].audioRecorder.url absoluteString];
        [ChatAttachmentHelperClass sharedInstance].attachmentData = [NSData dataWithContentsOfURL:[ChatAttachmentHelperClass sharedInstance].audioRecorder.url];
        [[ChatAttachmentHelperClass sharedInstance].audioRecordingTimer invalidate];
        [ChatAttachmentHelperClass sharedInstance].audioRecordingTimer = nil;
        [self removeFromSuperview];
        [chatViewController btnSendMessagePressed:nil];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (IBAction)btnStartStopAudioRecordingPressed:(id)sender
{
    UIButton *btn1 = (UIButton *)sender;
    btn1.selected = !btn1.selected;
    
    if (!btn1.selected)
    {
        // Stop Audio Recording
        [[ChatAttachmentHelperClass sharedInstance].audioRecorder pause];
        self.btn2.selected = YES;
        [[ChatAttachmentHelperClass sharedInstance].audioRecordingTimer invalidate];
        [ChatAttachmentHelperClass sharedInstance].audioRecordingTimer = nil;
    }
    else
    {
        // Start Audio Recording
        if ([ChatAttachmentHelperClass sharedInstance].audioRecorder.currentTime)
        {
            [[ChatAttachmentHelperClass sharedInstance].audioRecorder record];
            [ChatAttachmentHelperClass sharedInstance].audioRecordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                                    target:self
                                                                  selector:@selector(updateRecordingProgress)
                                                                  userInfo:nil
                                                                   repeats:YES];
        }
        else
        {
            self.recorderProgressView.progress = 0;
            [[ChatAttachmentHelperClass sharedInstance] startAudioRecording];

        }
    }
}

- (IBAction)btnDismissRecordingPressed:(id)sender
{
    [self removeFromSuperview];
}

- (void)updateRecordingProgress
{
    self.recorderProgressView.progress = [ChatAttachmentHelperClass sharedInstance].audioRecorder.currentTime/10.0f;
}

@end
