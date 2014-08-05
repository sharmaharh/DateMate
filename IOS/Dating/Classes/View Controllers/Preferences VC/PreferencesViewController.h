//
//  PreferencesViewController.h
//  Dating
//
//  Created by Harsh Sharma on 05/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookUtility.h"

@interface PreferencesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *switchPrefferedSex;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPrefferdLowerAge;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPrefferdUpperAge;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPrefferdRadius;

- (IBAction)buttonSubmitPrefferencesPressed:(id)sender;

@end
