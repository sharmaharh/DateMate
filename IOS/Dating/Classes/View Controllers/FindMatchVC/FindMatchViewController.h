//
//  FindMatchViewController.h
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindMatchViewController : UIViewController

- (IBAction)passProfileButtonPressed:(id)sender;
- (IBAction)passEmotionsButtonPressed:(id)sender;
- (IBAction)btnProfileDetailPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnPassProfile;
@property (strong, nonatomic) IBOutlet UIButton *btnProfileImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;

@property (strong, nonatomic) IBOutlet UIView *upcomingProfilesView;

@end
