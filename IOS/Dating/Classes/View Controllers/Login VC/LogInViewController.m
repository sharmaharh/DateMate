//
//  LogInViewController.m
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "LogInViewController.h"
#import "FindMatchViewController.h"
#import "RearMenuViewController.h"

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
        NSString *paramsString = @"id, name, first_name, last_name, gender, picture.type(square), email, birthday, location";
    NSArray *permissionsArray = @[@"read_stream",@"email",@"user_birthday",@"user_location"];
//    
//    [[FacebookUtility sharedObject]fetchFBPersonalInfoWithParams:paramsString withPermissions:permissionsArray completionHandler:^(id response, NSError *e) {
//        if (!e)
//        {
//            fbDict = response;
//        }
//        else
//        {
//            [Utils showOKAlertWithTitle:@"Dating" message:@"Failed to Fetch Data from Facebook"];
//        }
//    }];
    
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
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        [FacebookUtility sharedObject].fbID = fbDict[@"id"];
        [FacebookUtility sharedObject].fbFullName = fbDict[@"name"];
        [[NSUserDefaults standardUserDefaults] setObject:[FacebookUtility sharedObject].fbID forKey:@"fbID"];
        [[NSUserDefaults standardUserDefaults] setObject:[FacebookUtility sharedObject].fbID forKey:@"fbFullName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
#if TARGET_IPHONE_SIMULATOR
        NSDictionary *fbInfo = @{@"ent_first_name":fbDict[@"first_name"], @"ent_last_name":fbDict[@"last_name"], @"ent_fbid":fbDict[@"id"], @"ent_sex":@"1", @"ent_curr_lat":@"28.500", @"ent_curr_long":@"77.3", @"ent_dob":@"1991-01-29", @"ent_push_token" : @"iPhone_Simulator", @"ent_profile_pic":fbDict[@"picture"][@"data"][@"url"], @"ent_device_type":@"1", @"ent_auth_type":@"1"};
#else
        
        NSDictionary *fbInfo = @{@"ent_first_name":fbDict[@"first_name"], @"ent_last_name":fbDict[@"last_name"], @"ent_fbid":fbDict[@"id"], @"ent_sex":@"1", @"ent_curr_lat":@"28.500", @"ent_curr_long":@"77.3", @"ent_dob":@"1991-01-29", @"ent_push_token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"], @"ent_profile_pic":fbDict[@"picture"][@"data"][@"url"], @"ent_device_type":@"1", @"ent_auth_type":@"1"};
        
#endif
        
        [self.activityIndicator startAnimating];
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"login" withParamData:[fbInfo mutableCopy] withBlock:^(id response, NSError *error) {
            [self.activityIndicator stopAnimating];
            
            // Save Auth Token
            
            [[NSUserDefaults standardUserDefaults] setObject:response[@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
            appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
            
            RearMenuViewController *rearMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
            appDelegate.revealController = [[SWRevealViewController alloc] initWithRearViewController:rearMenuViewController frontViewController:appDelegate.frontNavigationController];
            
            [appDelegate.window setRootViewController:appDelegate.revealController];
            
            [appDelegate.window makeKeyAndVisible];
            
            
        }];
    }
    
    
    
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
