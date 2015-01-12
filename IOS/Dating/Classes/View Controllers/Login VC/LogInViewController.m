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
    CLLocationManager *locationManager;
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
    [self customizeLoginView];
    [[Utils sharedInstance] startLocationManager];
}

- (void)customizeLoginView
{
    [self.lblFacebookLogo.layer setCornerRadius:self.lblFacebookLogo.frame.size.height/2];
    [self.btnFacebook.layer setBorderWidth:0.5f];
    [self.btnFacebook.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.btnFacebook.layer setCornerRadius:self.btnFacebook.frame.size.height/2];
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
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
        return;
    }
    
    NSString *paramsString = @"id, name, first_name, last_name, gender, picture.type(large), email, birthday, location";
    NSArray *permissionsArray = @[@"read_stream",@"email",@"user_birthday",@"user_location",@"user_likes"];
    
    [[FacebookUtility sharedObject] fetchFBPersonalInfoWithParams:paramsString withPermissions:permissionsArray completionHandler:^(id response, NSError *e) {
        if (!e)
        {
            fbDict = response;
            [self fetchProfilePhotoWithFBResponse:response];
        }
        else
        {
            [Utils showOKAlertWithTitle:_Alert_Title message:@"Failed to Fetch Info from Facebook, Please try again later."];
        }
    }];
    
}

- (void)fetchProfilePhotoWithFBResponse:(NSDictionary *)fbResponse
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
                         [self parseLogin:fbResponse];
                     }
                     
                 }];
            }
            else
            {
                [Utils showOKAlertWithTitle:_Alert_Title message:@"Oops, an error occured in fetching Profile Photos.Please try again."];
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

#pragma mark -
#pragma mark -  login Parse methods

-(void)parseLogin :(NSDictionary*)FBUserDetailDict
{
    /*
     {
     birthday = "01/29/1991";
     email = "sharmaharh@gmail.com";
     "first_name" = Harsh;
     gender = male;
     id = 661762160568643;
     "last_name" = Sharma;
     location =     {
     id = 130646063637019;
     name = "Noida, India";
     };
     name = "Harsh Sharma";
     picture =     {
     data =         {
     "is_silhouette" = 0;
     url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p200x200/10173685_699047186840140_8668638152027902863_n.jpg?oh=be8409d6c8737a2806d893fa7177d797&oe=5516186E&__gda__=1426009299_ae7e0adbc908281bd18a12f6a9483f5b";
     };
     };
     }
     */
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
    appDelegate.userPreferencesDict = [NSMutableDictionary dictionary];
    [appDelegate.userPreferencesDict setObject:@"20" forKey:@"ent_pref_lower_age"];
    [appDelegate.userPreferencesDict setObject:@"26" forKey:@"ent_pref_upper_age"];
    [appDelegate.userPreferencesDict setObject:@"100" forKey:@"ent_pref_radius"];
    [appDelegate.userPreferencesDict setObject:fbDict[@"id"] forKey:@"ent_user_fbid"];
    [appDelegate.userPreferencesDict setObject:[FBUserDetailDict[@"gender"] isEqualToString:@"male"]?@"1":@"2" forKey:@"ent_sex"];
    
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {
        [FacebookUtility sharedObject].fbID = fbDict[@"id"];
        [FacebookUtility sharedObject].fbFullName = fbDict[@"name"];
        [[NSUserDefaults standardUserDefaults] setObject:[FacebookUtility sharedObject].fbID forKey:@"fbID"];
        [[NSUserDefaults standardUserDefaults] setObject:[FacebookUtility sharedObject].fbFullName forKey:@"fbFullName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *profilePicString = @"";
        
        for (int i = 0; i < MIN(4, [profilePicsArray count]); i++)
        {
            NSDictionary *dict = profilePicsArray[i];
            profilePicString = [profilePicString stringByAppendingString:[NSString stringWithFormat:@"%@,",dict[@"source"]]];
        }
        
        if ([profilePicString length])
        {
            profilePicString = [profilePicString substringToIndex:profilePicString.length-1];
        }
        
        
#if TARGET_IPHONE_SIMULATOR
        
        NSDictionary *fbInfo = @{@"ent_first_name":fbDict[@"first_name"], @"ent_last_name":fbDict[@"last_name"], @"ent_fbid":fbDict[@"id"], @"ent_sex":appDelegate.userPreferencesDict, @"ent_curr_lat":@"28.500", @"ent_curr_long":@"77.3", @"ent_dob":[self DOBofUserAsPerFB:FBUserDetailDict[@"birthday"]], @"ent_push_token" : @"iPhone_Simulator", @"ent_profile_pic":profilePicString, @"ent_device_type":@"1", @"ent_auth_type":@"1"};
#else
        
        NSDictionary *fbInfo = @{@"ent_first_name":fbDict[@"first_name"], @"ent_last_name":fbDict[@"last_name"], @"ent_fbid":fbDict[@"id"], @"ent_sex":appDelegate.userPreferencesDict, @"ent_curr_lat":@"28.500", @"ent_curr_long":@"77.3", @"ent_dob":[self DOBofUserAsPerFB:FBUserDetailDict[@"birthday"]], @"ent_push_token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"], @"ent_profile_pic":profilePicString, @"ent_device_type":@"1", @"ent_auth_type":@"1"};
        
#endif
        
        [self.activityIndicator startAnimating];
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"login" withParamData:[fbInfo mutableCopy] withBlock:^(id response, NSError *error) {
            [self.activityIndicator stopAnimating];
            if (!error)
            {
                if ([response[@"profilePic"] length])
                {
                    [reqImageArray addObject:response[@"profilePic"]];
                }
                
                if ([response[@"otherPic"] isKindOfClass:[NSArray class]])
                {
                    for (NSDictionary *dict in response[@"otherPic"])
                    {
                        [reqImageArray addObject:dict[@"url"]];
                    }

                }
                
                [self performSegueWithIdentifier:@"loginToSelectGenderIdentifier" sender:self];

                // Save Auth Token
                [[NSUserDefaults standardUserDefaults] setObject:response[@"token"] forKey:@"token"];
                
            }
            else
            {
                [Utils showOKAlertWithTitle:_Alert_Title message:@"Oops, an error occured while logging in your profile. Please try again later."];
            }
        }];
    }

}

- (NSString *)DOBofUserAsPerFB:(NSString *)dobString
{
    //"01/29/1991"
    //@"1991-01-29"
    NSMutableArray *dobComponents = [[dobString componentsSeparatedByString:@"/"] mutableCopy];
    [dobComponents insertObject:[dobComponents lastObject] atIndex:0];
    [dobComponents removeLastObject];
    
    return [dobComponents componentsJoinedByString:@"-"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:reqImageArray forKey:@"ProfileImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[Utils sharedInstance] stopUpdatingLocation];
    [super viewDidDisappear:animated];
}

@end
