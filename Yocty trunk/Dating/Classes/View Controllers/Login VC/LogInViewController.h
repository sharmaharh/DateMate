//
//  LogInViewController.h
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController

#pragma mark -------
#pragma mark IBActions

- (IBAction)btnLoginFBPressed:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UILabel *lblFacebookLogo;


@end