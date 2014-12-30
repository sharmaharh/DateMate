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

- (IBAction)passProfileButtonPressed:(id)sender;
- (IBAction)passEmotionsButtonPressed:(id)sender;
- (IBAction)btnProfileDetailPressed:(id)sender;
- (IBAction)btnDIsmissTutorialPressed:(id)sender;
- (IBAction)btnDismissRequestSentPressed:(id)sender;

- (void)displayTime;

@property (strong, nonatomic) NSTimer *profileTimer;
@property (assign, nonatomic) NSInteger currentProfileIndex;

@property (strong, nonatomic) IBOutlet UIButton *btnPassProfile;
@property (strong, nonatomic) IBOutlet UIButton *btnProfileImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewPreferences;
@property (strong, nonatomic) IBOutlet UILabel *lblTimer;

@property (strong, nonatomic) IBOutlet UIView *upcomingProfilesView;

@property (strong, nonatomic) IBOutlet UIView *viewTutorial;

@property (strong, nonatomic) IBOutlet UILabel *viewTutorialUpcomingProfile;

@property (strong, nonatomic) IBOutlet UILabel *viewTutorialTimer;

@property (strong, nonatomic) IBOutlet UIView *viewRequestSent;
@property (strong, nonatomic) IBOutlet UILabel *lblRequestSent;
@property (weak, nonatomic) IBOutlet SFCountdownView *sfCountdownView;

@end
