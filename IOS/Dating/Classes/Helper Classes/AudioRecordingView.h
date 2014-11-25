//
//  AudioRecordingView.h
//  Dating
//
//  Created by Harsh Sharma on 11/7/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioRecordingView : UIView

@property (strong, nonatomic) IBOutlet UIProgressView *recorderProgressView;
@property (strong, nonatomic) IBOutlet UIButton *btn1;
@property (strong, nonatomic) IBOutlet UIButton *btn2;

- (IBAction)btnSendAudioPressed:(id)sender;

- (IBAction)btnStartStopAudioRecordingPressed:(id)sender;
- (IBAction)btnDismissRecordingPressed:(id)sender;

- (void)updateRecordingProgress;

@end
