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
    [self performSegueWithIdentifier:@"PreferencesToChatIdentifier" sender:self];
    NSDictionary *responseDict = @{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_sex" : @"1" , @"ent_pref_sex" : [NSString stringWithFormat:@"%i",self.switchPrefferedSex.on+1], @"ent_pref_lower_age" : self.textfieldPrefferdLowerAge.text , @"ent_pref_upper_age" : self.textfieldPrefferdUpperAge.text , @"ent_pref_radius" : self.textfieldPrefferdRadius.text};
    
    AFNHelper *afnhelper = [AFNHelper new];
    [afnhelper getDataFromPath:@"updatePreferences" withParamData:[responseDict mutableCopy] withBlock:^(id response, NSError *error) {
        [self performSegueWithIdentifier:@"LoginToPreferncesViewController" sender:self];
        
        NSLog(@"%@",response);
    }];
}



#pragma mark UITextField Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textField.inputAccessoryView = keyboardDoneButtonView;
    return YES;
}

- (void)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
