//
//  PreferencesViewController.m
//  Dating
//
//  Created by Harsh Sharma on 05/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "PreferencesViewController.h"
#import "FindMatchViewController.h"

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
    NSMutableArray *array = [NSMutableArray array];
    
    if (!self.textfieldPrefferdUpperAge.text.length)
    {
        [array addObject:@"- Upper Age"];
    }
    if (!self.textfieldPrefferdLowerAge.text.length)
    {
        [array addObject:@"- Lower Age"];
    }
    if (!self.textfieldPrefferdRadius.text.length)
    {
        [array addObject:@"- Area Range (Radius)"];
    }
    
    if (array.count)
    {
        NSString *tempStr = @"Please fill the following Information \n:";
        tempStr = [tempStr stringByAppendingString:[array componentsJoinedByString:@"\n"]];
        [Utils showOKAlertWithTitle:@"Dating" message:tempStr];
        return;
    }
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        [self.activityIndicator startAnimating];
        NSDictionary *responseDict = @{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_sex" : @"1" , @"ent_pref_sex" : [NSString stringWithFormat:@"%i",self.segmentPrefferedSex.state+1], @"ent_pref_lower_age" : self.textfieldPrefferdLowerAge.text , @"ent_pref_upper_age" : self.textfieldPrefferdUpperAge.text , @"ent_pref_radius" : self.textfieldPrefferdRadius.text};
        
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"updatePreferences" withParamData:[responseDict mutableCopy] withBlock:^(id response, NSError *error) {
            [self.activityIndicator stopAnimating];
            FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
            [appDelegate.revealController setContentViewController:navigationController animated:YES];
            
            NSLog(@"%@",response);
        }];
    }

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
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setTransform:CGAffineTransformMakeTranslation(0, -130)];
    }];
    return YES;
}

- (void)doneClicked:(id)sender
{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
