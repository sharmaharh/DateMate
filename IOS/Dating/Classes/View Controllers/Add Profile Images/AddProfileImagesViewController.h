//
//  AddProfileImagesViewController.h
//  Dating
//
//  Created by Harsh Sharma on 9/24/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddProfileImagesViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *profileImagesArray;

@property (weak, nonatomic) IBOutlet UIButton *imgViewProfilePic1;
@property (weak, nonatomic) IBOutlet UIButton *imgViewProfilePic2;
@property (weak, nonatomic) IBOutlet UIButton *imgViewProfilePic3;
@property (weak, nonatomic) IBOutlet UIButton *imgViewProfilePic4;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorProfilePic1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorProfilePic2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorProfilePic3;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorProfilePic4;


- (IBAction)btnEditPressed:(id)sender;
- (IBAction)btnKeepConnectingPressed:(id)sender;

@end
