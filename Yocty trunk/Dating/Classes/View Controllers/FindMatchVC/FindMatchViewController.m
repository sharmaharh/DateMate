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
#import <Social/Social.h>

@interface FindMatchViewController ()
{
    NSMutableArray *matchedProfilesArray;
    NSInteger imageDownloadedCount;
    BOOL isFirstProfilePassed;
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
    [self customizeView];
    imageDownloadedCount = 0;
    [self findMatchesList];
}

- (void)customizeView
{
    self.btnStare.layer.borderWidth = 1.0f;
    self.btnStare.layer.cornerRadius = self.btnStare.frame.size.height/2;
    self.btnStare.layer.borderColor = [UIColor whiteColor].CGColor;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileOnLayout
{
    [self hideViewWhileTranstioning];
    NSDictionary *profileDict = matchedProfilesArray[self.currentProfileIndex];
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    [self.btnProfileImage setImage:nil forState:UIControlStateNormal];
    
    [self setImageOnButton:self.btnProfileImage WithImageURL:[matchedProfilesArray[self.currentProfileIndex][@"oPic"] firstObject][@"url"]];
    [self setUpcomingProfilesInFindMatchesList];
    
    self.lblTimer.text = @"9";
    [self.profileTimer invalidate];
    
    self.profileTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
}

- (void)displayTime
{
    if (imageDownloadedCount == MIN(4, (matchedProfilesArray.count - self.currentProfileIndex + 1)) && [self.viewTutorial isHidden])
    {
        [self.btnProfileImage setUserInteractionEnabled:YES];
        
        if (self.lblTimer.text.intValue < 2)
        {
            [self.btnProfileImage setUserInteractionEnabled:NO];
            [self.profileTimer invalidate];
            [self passProfileButtonPressed:nil];
            return;
        }
        
        else if (self.lblTimer.text.intValue == 4)
        {
            [self.sfCountdownView start];
        
        }
        
        [self.lblTimer setText:[NSString stringWithFormat:@"%i",[[self.lblTimer text] intValue]-1]];
    
    }

}

- (IBAction)btnInviteSomebodyPressed:(id)sender
{
    [[Utils sharedInstance] openActionSheetWithTitle:@"Invite" buttons:@[@"Facebook",@"Twitter"] completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        if (buttonIndex == 0)
        {
            //Facebook
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                SLComposeViewController *fbComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [fbComposer setInitialText:@"Explore the world of Yocty in your hands. Download now"];
                [fbComposer addImage:[UIImage imageNamed:@"app_logo"]];
                [fbComposer addURL:[NSURL URLWithString:@""]];
            }
            else
            {
                [Utils showOKAlertWithTitle:_Alert_Title message:@"Please login to Facebook Account in Settings."];
            }
        }
        else if(buttonIndex == 1)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *twitterComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [twitterComposer setInitialText:@"Explore the world of Yocty in your hands. Download now"];
                [twitterComposer addImage:[UIImage imageNamed:@"app_logo"]];
                [twitterComposer addURL:[NSURL URLWithString:@""]];
            }
            else
            {
                [Utils showOKAlertWithTitle:_Alert_Title message:@"Please login to Twitter Account in Settings."];
            }

        }
    }];
}

- (void) countdownFinished:(SFCountdownView *)view
{
    NSLog(@"COUNTDOWN FINISHED METHOD");
    [self.view setNeedsDisplay];
    [view updateAppearance];
    [self passProfileButtonPressed:nil];
    
}

- (void)setImageOnButton:(UIButton *)btn WithImageURL:(NSString *)ImageURL
{
    [btn.imageView setContentMode:UIViewContentModeCenter];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:ImageURL withFBID:matchedProfilesArray[self.currentProfileIndex][@"fbId"] withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        
        imageDownloadedCount ++;
        
        if (!error)
        {
            [btn setImage:[Utils scaleImage:image WithRespectToFrame:btn.frame] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"Bubble-0"] forState:UIControlStateNormal];
        }
        
        if (imageDownloadedCount == MIN(4, (matchedProfilesArray.count - self.currentProfileIndex + 1)))
        {
            [self showImagesAfterAllDownloading];
        }
    }];
    
}

- (void)setImageOnImageView:(UIImageView *)imgView WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator WithImageURL:(NSString *)ImageURL WithFBId:(NSString *)fbID
{
    [imgView setContentMode:UIViewContentModeCenter];
    [activityIndicator startAnimating];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:ImageURL withFBID:fbID withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        [activityIndicator stopAnimating];
        imageDownloadedCount ++;
        if (!error)
        {
            [imgView setImage:[Utils scaleImage:image WithRespectToFrame:imgView.frame]];
        }
        else
        {
            [imgView setImage:[UIImage imageNamed:@"Bubble-0"]];
        }
        
        if (imageDownloadedCount == MIN(4, (matchedProfilesArray.count - self.currentProfileIndex + 1)))
        {
            [self showImagesAfterAllDownloading];
        }
    }];
    
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
    [self hideViewWhileTranstioning];
    [self setUpCountdownView];
    
    matchedProfilesArray = [NSMutableArray array];
    
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[Utils sharedInstance] startHSLoaderInView:self.view];
        });
        
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
                         [self downloadNextProfileImages];
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
    UIView *errorMsgView = (UIView *)[self.view viewWithTag:4];
    [errorMsgView setHidden:NO];
    [[Utils sharedInstance] stopHSLoader];
}

- (void)showImagesAfterAllDownloading
{
    for (NSInteger i = self.currentProfileIndex; i < MIN(matchedProfilesArray.count, self.currentProfileIndex+3); i++)
    {
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-self.currentProfileIndex];
        [imageView setHidden:NO];
    }
    [self.viewTutorial setHidden:[[NSUserDefaults standardUserDefaults] boolForKey:@"FindMatchStare"]];
    [self.viewTutorialTimer setHidden:[[NSUserDefaults standardUserDefaults] boolForKey:@"FindMatchStare"]];
    
    if (isFirstProfilePassed && ![[NSUserDefaults standardUserDefaults] boolForKey:@"FindMatchUpcoming"])
    {
        [self.viewTutorialUpcomingProfile setHidden:NO];
        [self.imgViewTutorial setImage:[UIImage imageNamed:@"tutorial_Upcoming_Profile"]];
        [self.viewTutorial setHidden:NO];
    }
    [[self.view viewWithTag:1] setHidden:NO];
    [[self.view viewWithTag:2] setHidden:NO];
    [[self.view viewWithTag:3] setHidden:NO];
    [[self.view viewWithTag:4] setHidden:YES];
    [self.viewUserDetails setHidden:NO];
    [self.lblTimer setHidden:NO];
    
    [[Utils sharedInstance] stopHSLoader];
}


- (void)hideViewWhileTranstioning
{
    UIView *errorMsgView = (UIView *)[self.view viewWithTag:4];
    [errorMsgView setHidden:YES];
    
    for (NSInteger i = self.currentProfileIndex; i < MIN(matchedProfilesArray.count, self.currentProfileIndex+3); i++)
    {
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-self.currentProfileIndex];
        [imageView setHidden:YES];
    }
    [[self.view viewWithTag:1] setHidden:YES];
    
    [self.viewUserDetails setHidden:YES];
    [self.lblTimer setHidden:YES];
    
}

- (void)passProfileButtonPressed:(id)sender
{
    self.currentProfileIndex++;
    imageDownloadedCount = 0;
    if (!isFirstProfilePassed)
    {
        isFirstProfilePassed = YES;
        
    }
    if (self.currentProfileIndex < matchedProfilesArray.count)
    {
        
        [self setProfileOnLayout];
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
    imageDownloadedCount = 0;
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

- (void)downloadNextProfileImages
{
    
    if ((self.currentProfileIndex + 4) < [matchedProfilesArray count])
    {
        NSInteger startingIndex = self.currentProfileIndex + 4;
        
        for (NSInteger i = startingIndex ; i < [matchedProfilesArray count]; i++)
        {
            
            [[HSImageDownloader sharedInstance] imageWithImageURL:[matchedProfilesArray[i][@"oPic"] firstObject][@"url"] withFBID:matchedProfilesArray[i][@"fbId"] withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
                NSLog(@"Profile Image at Index downloaded = %i",i);
            }];
        }
    }
    
    
}

- (IBAction)passEmotionsButtonPressed:(id)sender
{
    [self.profileTimer invalidate];
    [self setUpCountdownView];
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
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
    if (isFirstProfilePassed)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FindMatchUpcoming"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FindMatchStare"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        [self setImageOnImageView:imageView WithActivityIndicator:nil WithImageURL:[matchedProfilesArray[i][@"oPic"] firstObject][@"url"] WithFBId:matchedProfilesArray[i][@"fbId"]];
        
        
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
