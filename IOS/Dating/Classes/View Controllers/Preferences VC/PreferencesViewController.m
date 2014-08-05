//
//  PreferencesViewController.m
//  Dating
//
//  Created by Harsh Sharma on 05/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "PreferencesViewController.h"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonSubmitPrefferencesPressed:(id)sender
{
    NSDictionary *responseDict = @{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_sex" : @"1" , @"ent_pref_sex" : [NSString stringWithFormat:@"%i",self.switchPrefferedSex.on+1], @"ent_pref_lower_age" : self.textfieldPrefferdLowerAge.text , @"ent_pref_upper_age" : self.textfieldPrefferdUpperAge.text , @"ent_pref_radius" : self.textfieldPrefferdRadius.text};
    
}
@end
