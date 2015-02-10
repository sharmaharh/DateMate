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
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    NSString *paramsString = @"id, name, first_name, last_name, gender, picture.type(large), email, birthday, location, bio";
    NSArray *permissionsArray = @[@"email",@"user_birthday",@"user_location",@"user_likes"];
    [self.btnFacebook setUserInteractionEnabled:NO];

    [[Utils sharedInstance] startHSLoaderInView:self.view];
    [[FacebookUtility sharedObject] fetchFBPersonalInfoWithParams:paramsString withPermissions:permissionsArray completionHandler:^(id response, NSError *e) {
        if (!e)
        {
            fbDict = response;
            [self fetchProfilePhotoWithFBResponse:response];
        }
        else
        {
            [self.btnFacebook setUserInteractionEnabled:YES];
            
            [[Utils sharedInstance] stopHSLoader];
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
                     if (!error)
                     {
                         NSDictionary *responseDict = [NSDictionary dictionaryWithDictionary:response];
                         
                         if ([responseDict[@"data"] isKindOfClass:[NSArray class]])
                         {
                             profilePicsArray = [[self filterArrayInLikesDescendingOrderFromArray:responseDict[@"data"]] mutableCopy];
                             
                         }
                         else
                         {
                             profilePicsArray = [NSMutableArray array];
                             [self.btnFacebook setUserInteractionEnabled:YES];
                             [[Utils sharedInstance] stopHSLoader];
                         }
                         [self parseLogin:fbResponse];
                     }
                     else
                     {
                         [self.btnFacebook setUserInteractionEnabled:YES];
                         [[Utils sharedInstance] stopHSLoader];
                     }
                     
                 }];
            }
            else
            {
                [self.btnFacebook setUserInteractionEnabled:YES];
                [[Utils sharedInstance] stopHSLoader];
                [Utils showOKAlertWithTitle:_Alert_Title message:@"Oops, an error occured in fetching Profile Photos.Please try again."];
            }
        }
        else
        {
            [self.btnFacebook setUserInteractionEnabled:YES];
            [[Utils sharedInstance] stopHSLoader];
        }
        
    }];
}

- (NSArray *)filterArrayInLikesDescendingOrderFromArray:(NSArray *)imagesArray
{
    
    NSComparator imageLikesComparator = ^NSComparisonResult(NSDictionary *obj1,
                                                        NSDictionary *obj2) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        //2010-12-01T21:35:43+0000
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        NSDate *date1 = [df dateFromString:[obj1[@"created_time"] stringByReplacingOccurrencesOfString:@"T" withString:@""]];
        NSDate *date2 = [df dateFromString:[obj2[@"created_time"] stringByReplacingOccurrencesOfString:@"T" withString:@""]];
        
//        NSNumber *image1LikeCount = [NSNumber numberWithInteger:0];
//        NSNumber *image2LikeCount = [NSNumber numberWithInteger:0];
//        
//        
//        if ([[obj1 allKeys] containsObject:@"likes"])
//        {
//            image1LikeCount = [NSNumber numberWithInteger:[obj1[@"likes"][@"data"] count]];
//        }
//        
//        if ([[obj2 allKeys] containsObject:@"likes"])
//        {
//            image2LikeCount = [NSNumber numberWithInteger:[obj2[@"likes"][@"data"] count]];
//        }
        
        return [date2 compare:date1];
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
     bio = "The more u talk to me,
     \nThe more u get addicted to me........
     \n
     \nbloOd grouP=O+
     \nlol";
     birthday = "02/16/1991";
     email = "navneetsharma77navneet@gmail.com";
     "first_name" = Navneet;
     gender = male;
     id = 10203175848489479;
     "last_name" = Sharma;
     location =     {
     id = 112628452084970;
     name = Yamunanagar;
     };
     name = "Navneet Sharma";
     picture =     {
     data =         {
     "is_silhouette" = 0;
     url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xfa1/v/t1.0-1/p200x200/262217_3991638541793_1099481420_n.jpg?oh=1fa8cdb32dfae17cc7e994567471c94f&oe=552228C3&__gda__=1429444347_99413cb7f6c6b9dd962a8c72a714c550";
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
    if ([[fbDict allKeys] containsObject:@"bio"])
    {
        [appDelegate.userPreferencesDict setObject:fbDict[@"bio"] forKey:@"ent_pers_desc"];
    }
    else
    {
        [appDelegate.userPreferencesDict setObject:@"" forKey:@"ent_pers_desc"];
    }
    
    
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
        [self.btnFacebook setUserInteractionEnabled:YES];
    }
    else
    {
        [FacebookUtility sharedObject].fbID = fbDict[@"id"];
        [FacebookUtility sharedObject].fbFullName = fbDict[@"name"];
        
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
        
        NSString *currentLat = @"0.0";
        NSString *currentLong = @"0.0";
        
        if ([[Utils sharedInstance].locationManager location])
        {
            currentLat = [NSString stringWithFormat:@"%f",[Utils sharedInstance].locationManager.location.coordinate.latitude];
            currentLong = [NSString stringWithFormat:@"%f",[Utils sharedInstance].locationManager.location.coordinate.longitude];
        }
        
        
#if TARGET_IPHONE_SIMULATOR
        
        NSDictionary *fbInfo = @{@"ent_first_name":fbDict[@"first_name"], @"ent_last_name":fbDict[@"last_name"], @"ent_fbid":fbDict[@"id"], @"ent_sex":appDelegate.userPreferencesDict[@"ent_sex"], @"ent_curr_lat":currentLat, @"ent_curr_long":currentLong, @"ent_dob":[self DOBofUserAsPerFB:FBUserDetailDict[@"birthday"]], @"ent_push_token" : @"iPhone_Simulator", @"ent_profile_pic":profilePicString, @"ent_device_type":@"1", @"ent_auth_type":@"1",@"ent_pers_desc":appDelegate.userPreferencesDict[@"ent_pers_desc"]};
#else
        
        NSDictionary *fbInfo = @{@"ent_first_name":fbDict[@"first_name"], @"ent_last_name":fbDict[@"last_name"], @"ent_fbid":fbDict[@"id"], @"ent_sex":[NSString stringWithFormat:@"%i",[appDelegate.userPreferencesDict[@"ent_sex"] intValue]], @"ent_curr_lat":currentLat, @"ent_curr_long":currentLong, @"ent_dob":[self DOBofUserAsPerFB:FBUserDetailDict[@"birthday"]], @"ent_push_token" : [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]:@"iPhone_Simulator", @"ent_profile_pic":profilePicString, @"ent_device_type":@"1", @"ent_auth_type":@"1",@"ent_pers_desc":appDelegate.userPreferencesDict[@"ent_pers_desc"]};
        
#endif
        
        
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"login" withParamData:[fbInfo mutableCopy] withBlock:^(id response, NSError *error) {
            [self.btnFacebook setUserInteractionEnabled:YES];
            [[Utils sharedInstance] stopHSLoader];
            
            if (!error)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[FacebookUtility sharedObject].fbID forKey:@"fbID"];
                [[NSUserDefaults standardUserDefaults] setObject:[FacebookUtility sharedObject].fbFullName forKey:@"fbFullName"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if ([response[@"profilePic"] length])
                {
                    [reqImageArray addObject:response[@"profilePic"]];
                    
                    [[HSImageDownloader sharedInstance] imageWithImageURL:response[@"profilePic"] withFBID:[FacebookUtility sharedObject].fbID withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
                        NSLog (@"Profile Pic Downloaded");
                    }];
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
    
    return [dobComponents componentsJoinedByString:@"-"]?[dobComponents componentsJoinedByString:@"-"]:@"";
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
