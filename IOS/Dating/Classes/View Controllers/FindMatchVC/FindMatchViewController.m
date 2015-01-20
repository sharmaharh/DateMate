//
//  FindMatchViewController.m
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "FindMatchViewController.h"
#import "RecentChatsViewController.h"
#import "FullImageViewController.h"
#import "UserProfileDetailViewController.h"
#import "PBJHexagonFlowLayout.h"

@interface FindMatchViewController ()
{
    NSMutableArray *matchedProfilesArray;
}
@end

@implementation FindMatchViewController

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
    self.btnStare.layer.borderWidth = 1.0f;
    self.btnStare.layer.cornerRadius = self.btnStare.frame.size.height/2;
    self.btnStare.layer.borderColor = [UIColor whiteColor].CGColor;
    [self findMatchesList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self setupTutorialView];
}

- (void)setUpCountdownView
{
    [self.sfCountdownView stop];
    [self.sfCountdownView setHidden:YES];
    self.sfCountdownView.delegate = self;
    self.sfCountdownView.backgroundAlpha = 0.2;
    self.sfCountdownView.countdownColor = [UIColor whiteColor];
    self.sfCountdownView.countdownFrom = 3;
    [self.sfCountdownView updateAppearance];
    self.sfCountdownView.finishText = @"";
}

- (void)setupTutorialView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FindMatch"])
    {
        [self.viewTutorial setHidden:NO];
        CALayer *glowLayer = [CALayer layer];
        glowLayer.shadowColor = [UIColor blackColor].CGColor;
        glowLayer.shadowRadius = 15.0f;
        glowLayer.shadowOpacity = 1.0f;
        glowLayer.shadowOffset = CGSizeZero;
        
        [glowLayer setBounds:CGRectMake(0, 0, 40, 40)];
        [self.viewTutorial.layer addSublayer:glowLayer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileOnLayout
{
    NSLog(@"CURRENT INDEX = %li",self.currentProfileIndex);
    NSDictionary *profileDict = matchedProfilesArray[self.currentProfileIndex];
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    [self.btnProfileImage setImage:nil forState:UIControlStateNormal];
    
    [self setImageOnButton:self.btnProfileImage WithActivityIndicator:self.activityIndicator WithImageURL:[matchedProfilesArray[self.currentProfileIndex][@"oPic"] firstObject][@"url"]];
    [self setUpcomingProfilesInFindMatchesList];
    [self.lblTimer setHidden:NO];
    self.lblTimer.text = @"10";
    [self.profileTimer invalidate];
    
    self.profileTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
}

- (void)displayTime
{
    if ([self.btnProfileImage currentImage]) 
    {
        [self.btnProfileImage setUserInteractionEnabled:YES];
        
        if (self.lblTimer.text.intValue < 2)
        {
            [self.btnProfileImage setUserInteractionEnabled:NO];
        }
        else if (self.lblTimer.text.intValue < 1)
        {
            [self.profileTimer invalidate];
            [self passProfileButtonPressed:nil];
        }
        else if (self.lblTimer.text.intValue == 4)
        {
            [self.sfCountdownView start];
            [self.lblTimer setHidden:YES];
        }
        [self.btnStare setTitle:[NSString stringWithFormat:@"Stare %i",[[self.lblTimer text] intValue]-1] forState:UIControlStateNormal];
        [self.lblTimer setText:[NSString stringWithFormat:@"%i",[[self.lblTimer text] intValue]-1]];
    }

}

- (void) countdownFinished:(SFCountdownView *)view
{
    NSLog(@"COUNTDOWN FINISHED METHOD");
    [self.view setNeedsDisplay];
    [view updateAppearance];
    [self passProfileButtonPressed:nil];
    [self.lblTimer setHidden:YES];
    
}

- (void)setImageOnButton:(UIButton *)btn WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator WithImageURL:(NSString *)ImageURL
{
    [btn.imageView setContentMode:UIViewContentModeCenter];
    [activityIndicator startAnimating];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:ImageURL withFBID:matchedProfilesArray[self.currentProfileIndex][@"fbId"] withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        [activityIndicator stopAnimating];
        
        if (!error)
        {
            [btn setImage:[Utils scaleImage:image WithRespectToFrame:btn.frame] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"Bubble-0"] forState:UIControlStateNormal];
        }
    }];
    
//    __block NSString *bigImageURLString = ImageURL;
//    //    BOOL doesExist = [arrFilePath containsObject:filePath];
//    
//    NSString *dirPath = [FileManager ProfileImageFolderPathWithFBID:matchedProfilesArray[self.currentProfileIndex][@"fbId"]];
//    NSString *filePath = [dirPath stringByAppendingPathComponent:[ImageURL lastPathComponent]];
//    
//    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
//    
//    if (doesExist)
//    {
//        UIImage *image = [Utils scaleImage:[UIImage imageWithContentsOfFile:filePath] WithRespectToFrame:btn.frame];
//        if (image)
//        {
//            
//            [btn setImage:image forState:UIControlStateNormal];
//            [activityIndicator stopAnimating];
//        }
//        else
//        {
//            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//            [self setImageOnButton:btn WithActivityIndicator:activityIndicator WithImageURL:ImageURL];
//        }
//    
//    }
//    else
//    {
//        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
//            
//            
//            __block NSData *imageData = nil;
//            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error)
//            {
//                if (!error)
//                {
//                    imageData = data;
//                    UIImage *image = nil;
//                    data = nil;
//                    image = [Utils scaleImage:[UIImage imageWithData:imageData] WithRespectToFrame:btn.frame];
//                    if (image == nil)
//                    {
//                        image = [UIImage imageNamed:@"Bubble-0"];
//                    }
//                    
//                    [btn setImage:image forState:UIControlStateNormal];
//                    
//                    [activityIndicator stopAnimating];
//                    
//                    // Write Image in Document Directory
//                    int64_t delayInSeconds = 0.4;
//                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//                    
//                    
//                    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
//                        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
//                        {
//                            if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
//                            {
//                                [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
//                            }
//                            
//                            [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
//                            imageData = nil;
//                        }
//                    });
//                }
//                
//            }];
//            
//            bigImageURLString = nil;
//            
//            
//        });
//    }
    
}

- (void)setImageOnImageView:(UIImageView *)imgView WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator WithImageURL:(NSString *)ImageURL
{
    [imgView setContentMode:UIViewContentModeCenter];
    [activityIndicator startAnimating];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:ImageURL withFBID:matchedProfilesArray[self.currentProfileIndex][@"fbId"] withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        [activityIndicator stopAnimating];
        [imgView setHidden:NO];
        if (!error)
        {
            [imgView setImage:[Utils scaleImage:image WithRespectToFrame:imgView.frame]];
        }
        else
        {
            [imgView setImage:[UIImage imageNamed:@"Bubble-0"]];
        }
    }];
    
    
//    [imgView setContentMode:UIViewContentModeCenter];
//    if (!ImageURL || !ImageURL.length) {
//        return;
//    }
//    __block NSString *bigImageURLString = ImageURL;
//    //    BOOL doesExist = [arrFilePath containsObject:filePath];
//    
//    NSString *dirPath = [FileManager ProfileImageFolderPathWithFBID:matchedProfilesArray[self.currentProfileIndex][@"fbId"]];
//    NSString *filePath = [dirPath stringByAppendingPathComponent:[ImageURL lastPathComponent]];
//    
//    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
//    
//    if (doesExist)
//    {
//        UIImage *image = [Utils scaleImage:[UIImage imageWithContentsOfFile:filePath] WithRespectToFrame:imgView.frame];
//        if (image)
//        {
//            
//            [imgView setImage:image];
//            [activityIndicator stopAnimating];
//        }
//        else
//        {
//            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//            [self setImageOnImageView:imgView WithActivityIndicator:activityIndicator WithImageURL:ImageURL];
//        }
//        
//    }
//    else
//    {
//        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
//            
//            
//            __block NSData *imageData = nil;
//            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error)
//             {
//                 if (!error)
//                 {
//                     imageData = data;
//                     UIImage *image = nil;
//                     data = nil;
//                     image = [Utils scaleImage:[UIImage imageWithData:imageData] WithRespectToFrame:imgView.frame];
//                     if (image == nil)
//                     {
//                         image = [UIImage imageNamed:@"Bubble-0"];
//                     }
//                     
//                     [imgView setImage:image];
//                     
//                     [activityIndicator stopAnimating];
//                     
//                     // Write Image in Document Directory
//                     int64_t delayInSeconds = 0.4;
//                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//                     
//                     
//                     dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
//                         if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
//                         {
//                             if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
//                             {
//                                 [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
//                             }
//                             
//                             [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
//                             imageData = nil;
//                         }
//                     });
//                 }
//                 
//             }];
//            
//            bigImageURLString = nil;
//            
//            
//        });
//    }
    
}


- (void)showFullPicture:(UIButton *)btn
{
    FullImageViewController *fullImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FullImageViewController"];
    fullImageViewController.currentPhotoIndex = btn.tag-1;
    fullImageViewController.arrPhotoGallery = matchedProfilesArray[self.currentProfileIndex][@"oPic"];
    fullImageViewController.fbID = matchedProfilesArray[self.currentProfileIndex][@"fbId"];
    [self presentViewController:fullImageViewController animated:YES completion:nil];
}

- (void)findMatchesList
{
    [self resetView];
    [self showErrorInProfileView];
    
    matchedProfilesArray = [NSMutableArray array];
    
    [self setUpCountdownView];
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"findMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID} mutableCopy] withBlock:^(id response, NSError *error)
         {
             
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             if (![[response objectForKey:@"errFlag"] boolValue])
             {
                 if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
                 {
                     matchedProfilesArray = [[response objectForKey:@"matches"] mutableCopy];
                     if ([matchedProfilesArray count])
                     {
                         [self clubProfileImageInMainArray];
                         self.currentProfileIndex = 0;
                         [self setProfileOnLayout];
                         
                         [self showProfileViewWithoutError];
                     }
                     else
                     {
                         [self showErrorInProfileView];
                     }
                     
                 }
                 else
                 {
                     matchedProfilesArray = [NSMutableArray array];
                     [self showErrorInProfileView];
                 }
             }
             else
             {
                 [self showErrorInProfileView];
             }
             
         }];
    }

}

- (void)clubProfileImageInMainArray
{
    NSMutableArray *matchedProfileCopy = [matchedProfilesArray mutableCopy];
    for (NSDictionary *dict in matchedProfileCopy)
    {
        NSMutableDictionary *tempDict = [dict mutableCopy];
        NSMutableArray *tempArray = [[tempDict objectForKey:@"oPic"] mutableCopy];
        [tempArray insertObject:@{@"url" : tempDict[@"pPic"]} atIndex:0];
        [tempDict setObject:tempArray forKey:@"oPic"];
        [matchedProfilesArray replaceObjectAtIndex:[matchedProfilesArray indexOfObject:dict] withObject:tempDict];
    }
}

- (void)showProfileViewWithoutError
{
    for (int i = 1; i < 4 ; i++)
    {
        [[self.view viewWithTag:i] setHidden:NO];
    }
    UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:4];
    [errorMsgLabel setHidden:YES];
}

- (void)showErrorInProfileView
{
    for (int i = 1; i < 4 ; i++)
    {
        [[self.view viewWithTag:i] setHidden:YES];
    }
    UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:4];
    [errorMsgLabel setHidden:NO];
}

- (void)showWaitingForProfileDataView
{
    for (int i = 1; i < 4 ; i++)
    {
        [[self.view viewWithTag:i] setHidden:YES];
    }
}

- (void)passProfileButtonPressed:(id)sender
{
    [self removeCacheImages];
    self.currentProfileIndex++;
    
    if (self.currentProfileIndex < matchedProfilesArray.count)
    {
        [self setProfileOnLayout];
        [self setUpcomingProfilesInFindMatchesList];
        

    }
    else
    {
        [self showErrorInProfileView];
        self.lblTimer.text = @"";
    }
    [self.sfCountdownView stop];
}

- (void)resetView
{
    [self.sfCountdownView stop];
    [self.sfCountdownView updateAppearance];
    [self.btnProfileImage setImage:nil forState:UIControlStateNormal];
    self.lblTimer.text = @"";
    self.profileNameLabel.text = @"";
    for (UIImageView *imageView in self.upcomingProfilesView.subviews)
    {
        [imageView setImage:nil];
    }
}


- (void)removeCacheImages
{
    if (self.currentProfileIndex < [matchedProfilesArray count])
    {
        NSString *filePath = [FileManager ProfileImageFolderPathWithFBID:matchedProfilesArray[self.currentProfileIndex][@"fbId"]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    
}

- (IBAction)passEmotionsButtonPressed:(id)sender
{
    [self.profileTimer invalidate];
    [self setUpCountdownView];
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        AFNHelper *afnhelper = [AFNHelper new];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[self.currentProfileIndex][@"fbId"],@"1"] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
        
        [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self passProfileButtonPressed:nil];
                 });
                 
                 
                 if ([response[@"errMsg"] isEqualToString:@"Congrats! You got a match"]) {
                     // Now Winked Back, Start Conversation
                     [[Utils sharedInstance] openAlertViewWithTitle:@"Dating" message:response[@"errMsg"] buttons:@[@"Cancel",@"Chat"] completion:^(UIAlertView *alert, NSInteger buttonIndex)
                     {
                         if (buttonIndex)
                         {
                             
                             UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                             RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                             appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
                             recentChatViewController.isFromPush = NO;
                             [appDelegate.revealController setContentViewController:appDelegate.frontNavigationController animated:NO];
                             ChatViewController *chatViewConrtroller = [ChatViewController sharedChatInstance];
                             chatViewConrtroller.recieveFBID = response[@"uFbId"];
                             chatViewConrtroller.userName = response[@"uName"];
                             [appDelegate.frontNavigationController pushViewController:chatViewConrtroller animated:YES];
                         }
                         
                     }];
                     
                 }
                 else
                 {
                     if (self.currentProfileIndex < [matchedProfilesArray count])
                     {
                         [self.lblRequestSent setText:[NSString stringWithFormat:@"You Stared at %@",matchedProfilesArray[self.currentProfileIndex][@"firstName"]]];
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.viewRequestSent setHidden:NO];
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [self.viewRequestSent setHidden:YES];
                             });
                         });
                     }
                     
                     
                 }
                 
                 
             }
             else
             {
                 [Utils showOKAlertWithTitle:_Alert_Title message:@"Error Occured, Please Try Again"];
             }
             
         }];
    }
    
}

- (IBAction)btnProfileDetailPressed:(id)sender
{
    [self performSegueWithIdentifier:@"matchedProfileToProfileDetailIdentifier" sender:nil];
}

- (IBAction)btnDIsmissTutorialPressed:(id)sender
{
    [self.viewTutorial setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FindMatch"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.sfCountdownView stop];
    [self.profileTimer invalidate];
    
    UserProfileDetailViewController *userProfileDetailViewController = [segue destinationViewController];
    userProfileDetailViewController.matchedProfilesArray = matchedProfilesArray;
    userProfileDetailViewController.currentProfileIndex = self.currentProfileIndex;
    userProfileDetailViewController.isFromMatches = YES;
}

- (void)setUpcomingProfilesInFindMatchesList
{
    for (UIImageView *imageView in self.upcomingProfilesView.subviews)
    {
        [imageView setHidden:YES];
    }
    
    for (NSInteger i = self.currentProfileIndex; i < MIN(matchedProfilesArray.count, self.currentProfileIndex+3); i++)
    {
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-self.currentProfileIndex];
        [self setImageOnImageView:imageView WithActivityIndicator:nil WithImageURL:[matchedProfilesArray[i][@"oPic"] firstObject][@"url"]];
        
        if (i == self.currentProfileIndex)
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor greenColor] WithCornerRadius:15 WithLineWidth:3 withPathColor:[UIColor clearColor]];
        }
        else
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor lightGrayColor] WithCornerRadius:15  WithLineWidth:3 withPathColor:[UIColor clearColor]];
        }
        
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.profileTimer invalidate];
    self.profileTimer = nil;
    [super viewDidDisappear:animated];
}

@end
