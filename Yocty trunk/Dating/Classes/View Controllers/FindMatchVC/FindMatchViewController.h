//
//  FindMatchViewController.h
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFCountdownView.h"

@interface FindMatchViewController : UIViewController <SFCountdownViewDelegate>

- (IBAction)passEmotionsButtonPressed:(id)sender;
- (IBAction)btnProfileDetailPressed:(id)sender;
- (IBAction)btnDIsmissTutorialPressed:(id)sender;
- (void)passProfileButtonPressed:(id)sender;
- (void)findMatchesList;
- (void)displayTime;
- (IBAction)btnInviteSomebodyPressed:(id)sender;

@property (strong, nonatomic) NSTimer *profileTimer;
@property (assign, nonatomic) NSInteger currentProfileIndex;

@property (strong, nonatomic) IBOutlet UIButton *btnProfileImage;
@property (strong, nonatomic) IBOutlet UIButton *btnStare;
@property (strong, nonatomic) IBOutlet UIButton *btnInviteSomebody;
@property (strong, nonatomic) IBOutlet UILabel *bummerDetailTextLabel;

@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblTimer;
@property (strong, nonatomic) IBOutlet UIView *viewUserDetails;

@property (strong, nonatomic) IBOutlet UIView *upcomingProfilesView;

@property (strong, nonatomic) IBOutlet UIView *viewTutorial;

@property (strong, nonatomic) IBOutlet UILabel *viewTutorialUpcomingProfile;

@property (strong, nonatomic) IBOutlet UILabel *viewTutorialTimer;

@property (strong, nonatomic) IBOutlet UIView *viewRequestSent;
@property (strong, nonatomic) IBOutlet UILabel *lblRequestSent;
@property (strong, nonatomic) IBOutlet SFCountdownView *sfCountdownView;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewTutorial;

@end
