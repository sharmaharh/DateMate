//
//  LogInViewController.m
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "LogInViewController.h"
#import "AddProfileImagesViewController.h"
#import "FindMatchViewController.h"
#import "RearMenuViewController.h"

@interface LogInViewController ()
{
    NSDictionary *fbDict;
    NSMutableArray *profilePicsArray;
    NSMutableArray *reqImageArray;
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
    reqImageArray = [NSMutableArray array];
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
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
        return;
    }
    
    NSString *paramsString = @"id, name, first_name, last_name, gender, picture.type(large), email, birthday, location";
    NSArray *permissionsArray = @[@"read_stream",@"email",@"user_birthday",@"user_location",@"user_likes"];
    
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

- (void)fetchProfilePictureImagesBasedOnLikes
{
    profilePicsArray = [NSMutableArray array];
    [[FacebookUtility sharedObject] getUserProfilePicturesAlbumsWithCompletionBlock:^(id response, NSError *error) {
        if (!error)
        {
            if ([response isKindOfClass:[NSDictionary class]])
            {
                [[FacebookUtility sharedObject] getAlbumsPhotosWithLikes:response[@"id"] WithCompletionBlock:^(id response, NSError *error)
                 {
                     NSDictionary *responseDict = [NSDictionary dictionaryWithDictionary:response];
                
                     if ([responseDict[@"data"] isKindOfClass:[NSArray class]])
                     {
                         profilePicsArray = [[self filterArrayInLikesDescendingOrderFromArray:responseDict[@"data"]] mutableCopy];
                         [self uploadProfilePictures];
                         
                     }
                     
                 }];
            }
        }
        
    }];
    
}

- (NSArray *)filterArrayInLikesDescendingOrderFromArray:(NSArray *)imagesArray
{
    
    NSComparator imageLikesComparator = ^NSComparisonResult(NSDictionary *obj1,
                                                        NSDictionary *obj2) {
        NSNumber *image1LikeCount = [NSNumber numberWithInteger:0];
        NSNumber *image2LikeCount = [NSNumber numberWithInteger:0];
        
        
        if ([[obj1 allKeys] containsObject:@"likes"])
        {
            image1LikeCount = [NSNumber numberWithInteger:[obj1[@"likes"][@"data"] count]];
        }
        
        if ([[obj2 allKeys] containsObject:@"likes"])
        {
            image2LikeCount = [NSNumber numberWithInteger:[obj2[@"likes"][@"data"] count]];
        }
        
        return [image2LikeCount compare:image1LikeCount];
    };
    
    
    //    then simply sort the array by doing:
    return [imagesArray sortedArrayUsingComparator:imageLikesComparator];
    
}

- (void)uploadProfilePictures
{
    NSInteger count = 0;
    if (profilePicsArray.count < 3)
    {
        count = profilePicsArray.count;
    }
    else
        count = profilePicsArray.count;
    
    if (count > 0)
    {
        
        for (int i = 0; i < 3; i++)
        {
            [reqImageArray addObject:profilePicsArray[i][@"source"]];
        }
        [self.activityIndicator startAnimating];
        AFNHelper *afnHelper = [AFNHelper new];
        [afnHelper getDataFromPath:@"uploadImage" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID , @"ent_other_urls":[reqImageArray componentsJoinedByString:@","],@"ent_image_flag":@"1"} mutableCopy] withBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 NSLog(@"Response of Profile Picture Uploading Service = %@",response);
                 [self.activityIndicator stopAnimating];
                 [self performSegueWithIdentifier:@"LoginToProfilePicturesIdentifier" sender:self];
             }
             else
             {
                 [Utils showOKAlertWithTitle:@"Dating" message:@"Error in Uploading Images"];
             }
         }];
    }
    
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"LoginToProfilePicturesIdentifier"])
     {
         AddProfileImagesViewController *addProfileImagesViewController = [segue destinationViewController];
         addProfileImagesViewController.profileImagesArray = reqImageArray;
     }
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
            if (!error)
            {
                reqImageArray = [NSMutableArray arrayWithObject:response[@"profilePic"]];
                // Save Auth Token
                [[NSUserDefaults standardUserDefaults] setObject:response[@"token"] forKey:@"token"];
                [[NSUserDefaults standardUserDefaults] setObject:response forKey:@"ProfileInfo"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self fetchProfilePictureImagesBasedOnLikes];
                
            }
            
            
            // OPEN Screen To Watch Profile Images Uploaded.
            
            
//            FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
//            appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
//            
//            RearMenuViewController *rearMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
//            appDelegate.revealController = [[SWRevealViewController alloc] initWithRearViewController:rearMenuViewController frontViewController:appDelegate.frontNavigationController];
//            
//            [appDelegate.window setRootViewController:appDelegate.revealController];
//            
//            [appDelegate.window makeKeyAndVisible];
            
            
        }];
    }

}



@end
