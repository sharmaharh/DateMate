//
//  LogInViewController.m
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "LogInViewController.h"
#import "AFNHelper.h"


@interface LogInViewController ()
{
    NSDictionary *fbDict;
}
@end

@implementation LogInViewController

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

#pragma mark -------
#pragma mark IBActions

- (IBAction)btnLoginFBPressed:(id)sender
{
    [self performSegueWithIdentifier:@"LoginToChatIdentifier" sender:self];
//    NSString *paramsString = @"id, name, first_name, last_name, gender, picture.type(square), email, birthday, location";
//    NSArray *permissionsArray = @[@"read_stream",@"email",@"user_birthday",@"user_location"];
//    
//    [FacebookUtility fetchFBPersonalInfoWithParams:paramsString withPermissions:permissionsArray completionHandler:^(id response, NSError *e) {
//        if (!e)
//        {
//            fbDict = response;
//        }
//        else
//        {
//            [Utils showOKAlertWithTitle:@"Dating" message:@"Failed to Fetch Data from Facebook"];
//        }
//    }];
    
}

-(void)getFacebookUserDetails
{
    //me?fields=id,birthday,gender,first_name,age_range,last_name,name,picture.type(normal)
    
//    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
//    [pi showPIOnView:self.view withMessage:@"Logging In.."];
    [[FacebookUtility sharedObject]fetchMeWithFields:@"id,birthday,gender,first_name,age_range,last_name,name,picture.type(normal)" FBCompletionBlock:^(id response, NSError *error)
     {
         if (!error) {
             //                 [[UserDefaultHelper sharedObject] setFacebookUserDetail:[NSMutableDictionary dictionaryWithDictionary:response]];
             [self parseLogin:response];
         }
         else{
             //                 [pi hideProgressIndicator];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             alert.tag = 202;
             [alert show];
         }
     }];
    if ([[FacebookUtility sharedObject]isLogin]) {
        
    }
    else{
//        [pi hideProgressIndicator];
    }
    
}

#pragma mark -
#pragma mark -  login Parse methods

-(void)parseLogin :(NSDictionary*)FBUserDetailDict
{
    
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


@end
