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
//    [self performSegueWithIdentifier:@"LoginToChatIdentifier" sender:self];
    NSString *paramsString = @"id, name, first_name, last_name, gender, picture.type(square), email, birthday, location";
    NSArray *permissionsArray = @[@"read_stream",@"email",@"user_birthday",@"user_location"];
    
    [[FacebookUtility sharedObject]fetchFBPersonalInfoWithParams:paramsString withPermissions:permissionsArray completionHandler:^(id response, NSError *e) {
        if (!e)
        {
            fbDict = response;
            [self parseLogin:nil];
        }
        else
        {
            [Utils showOKAlertWithTitle:@"Dating" message:@"Failed to Fetch Data from Facebook"];
        }
    }];
    
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
    /*
     Response Parameters for Log In
     
     First Name *:   = "ent_first_name"
     Last Name :   name= "ent_last_name"
     FB Id:   ="ent_fbid"
     Sex *:   Male    Female          name="ent_sex"
     Current Latitude :   name="ent_curr_lat"
     Current Longitude :   name="ent_curr_long"
     Date Of Birth: (YYYY-MM-DD)  name="ent_dob"
     Push Token *:   name="ent_push_token"
     ent_profile_pic *:   name="ent_profile_pic"
     Device type *:   name="ent_device_type"
     Authentication type *:   name="ent_auth_type"
     *-marked are mandatory  name="ent_submit"
     */
    NSDictionary *fbInfo = @{@"ent_first_name":fbDict[@"first_name"], @"ent_last_name":fbDict[@"last_name"], @"ent_fbid":fbDict[@"id"], @"ent_sex":@"1", @"ent_curr_lat":@"0.0", @"ent_curr_long":@"0.0", @"ent_dob":@"1991-01-29", @"ent_push_token" : @"SIMULATOR_TEST", @"ent_profile_pic":fbDict[@"picture"][@"data"][@"url"], @"ent_device_type":@"1", @"ent_auth_type":@"1"};
    AFNHelper *afnhelper = [AFNHelper new];
    [afnhelper getDataFromURL:@"login" withBody:fbInfo withBlock:^(id response, NSError *error) {
        NSLog(@"%@",response);
    }];
//    [afnhelper callWebserviceWithMethod:@"login" andBody:<#(NSString *)#>]
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
