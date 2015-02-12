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

//NSLog Management
#ifdef _ENABLE_LOGGING
#   define NSLog(fmt, ...) NSLog((@"\n%s : [Line - %d] \n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define NSLog(fmt, ...)
#endif

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
//    [self hideViewWhileTranstioning];
    
    NSDictionary *profileDict = matchedProfilesArray[self.currentProfileIndex];
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    
    [self setImageOnButton:self.btnProfileImage WithImageURL:[profileDict[@"oPic"] firstObject][@"url"]];
    [self setUpcomingProfilesInFindMatchesList];
    
    self.lblTimer.text = @"9";
    
    if ([self.profileTimer isValid])
    {
        [self.profileTimer invalidate];
    }
    
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
    [[Utils sharedInstance] openActionSheetWithTitle:@"Invite" buttons:@[@"Facebook",@"Twitter",@"WhatsApp"] completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
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
        else if (buttonIndex == 2)
        {
            NSString * msg = @"Explore the world of Yocty in your hands. Download now";
            NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
            NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication] openURL: whatsappURL];
            } else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:_Alert_Title message:@"WhatsApp not installed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
}

- (void) countdownFinished:(SFCountdownView *)view
{
    NSLog(@"COUNTDOWN FINISHED METHOD");
    [self.view setNeedsDisplay];
    [view updateAppearance];
//    [self passProfileButtonPressed:nil];
    
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
            [imgView setBackgroundColor:[UIColor clearColor]];
        }
        else
        {
            [imgView setImage:nil];
            [imgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Bubble-0"]]];
        }
        
        [imgView setHidden:YES];
        
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
    self.currentProfileIndex = 0;
    [self resetView];
    [self hideViewWhileTranstioning];
    [self setUpCountdownView];
    
    matchedProfilesArray = [NSMutableArray array];
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
        [self showErrorInProfileViewWithBummerMessage:NO_INERNET_MSG hideInvitation:YES];
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIView *errorMsgView = (UIView *)[self.view viewWithTag:4];
            [errorMsgView setHidden:YES];
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
                         
                         [self setProfileOnLayout];
                         [self downloadNextProfileImages];
                     }
                     else
                     {
                         NSLog(@"Check");
                         [self showErrorInProfileViewWithBummerMessage:@"You got no one new around you" hideInvitation:NO];
                     }
                     
                 }
                 else
                 {
                     matchedProfilesArray = [NSMutableArray array];
                     NSLog(@"Check");
                     [self showErrorInProfileViewWithBummerMessage:@"You got no one new around you" hideInvitation:NO];
                 }
             }
             else
             {
                 NSLog(@"Check");
                 [self showErrorInProfileViewWithBummerMessage:@"You got no one new around you" hideInvitation:NO];
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

- (void)showErrorInProfileViewWithBummerMessage:(NSString *)message hideInvitation:(BOOL)shouldHide
{
    UIView *errorMsgView = (UIView *)[self.view viewWithTag:4];
    [self.bummerDetailTextLabel setText:message];
    [errorMsgView setHidden:NO];
    
    for (int i = 1; i < 4 ; i++)
    {
        [[self.view viewWithTag:i] setHidden:YES];
    }
    
    [[Utils sharedInstance] stopHSLoader];
}

- (void)showImagesAfterAllDownloading
{
    for (NSInteger i = 1; i < 4; i++)
    {
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-self.currentProfileIndex];
        [imageView setHidden:YES];
    }
    for (NSInteger i = self.currentProfileIndex; i < MIN(matchedProfilesArray.count, self.currentProfileIndex+3); i++)
    {
        
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-self.currentProfileIndex];
        if (imageView.image)
        {
            [imageView setHidden:NO];
        }
        else
        {
            [imageView setHidden:YES];
        }
        
        if (i == self.currentProfileIndex)
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor greenColor] WithCornerRadius:15 WithLineWidth:3 withPathColor:[UIColor clearColor]];
        }
        else
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor lightGrayColor] WithCornerRadius:15  WithLineWidth:3 withPathColor:[UIColor clearColor]];
        }
        
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
        NSLog(@"Check");
        [self showErrorInProfileViewWithBummerMessage:@"You got no one new around you" hideInvitation:YES];
        self.lblTimer.text = @"";
    }
    [self.sfCountdownView stop];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        if (![Utils isInternetAvailable])
        {
            [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
        }
        else
        {
            AFNHelper *afnhelper = [AFNHelper new];
            NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[self.currentProfileIndex][@"fbId"],@"6"] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
            
            [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
             {
                 
                 NSLog(@"Profile passed with success = %@",response);
                 
             }];
        }
        
    });
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
                NSLog(@"Profile Image at Index downloaded = %li",(long)i);
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
             /*
              {
              errFlag = 0;
              errMsg = "Congrats! You got a match";
              errNum = 55;
              pPic = "http://69.195.70.43/playground/ws/pics/10404248_787005571338697_2620196950764631887_n.jpg";
              uFbId = 848605118512075;
              uName = Rahul;
              }*/
             if (!error)
             {
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self passProfileButtonPressed:nil];
                 });
                 
                 
                 if ([response[@"errMsg"] isEqualToString:@"Congrats! You got a match"]) {
                     // Now Winked Back, Start Conversation
                     [[Utils sharedInstance] openAlertViewWithTitle:_Alert_Title message:response[@"errMsg"] buttons:@[@"Cancel",@"Chat"] completion:^(UIAlertView *alert, NSInteger buttonIndex)
                     {
                         if (buttonIndex)
                         {
                             
                             UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                             RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                             appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
                             [appDelegate.frontNavigationController setNavigationBarHidden:YES animated:YES];
                             
                             NSDictionary *messageDict = @{msg_Reciver_ID: response[@"uFbId"], msg_Sender_ID: [FacebookUtility sharedObject].fbID,msg_Sender_Name: response[@"uName"]};
                             recentChatViewController.nameArray = [@[messageDict] mutableCopy];
                             recentChatViewController.isFromPush = YES;
                             [appDelegate.revealController setContentViewController:appDelegate.frontNavigationController animated:NO];
//                             ChatViewController *chatViewConrtroller = [ChatViewController sharedChatInstance];
//                             chatViewConrtroller.recieveFBID = response[@"uFbId"];
//                             chatViewConrtroller.userName = response[@"uName"];
//                             [appDelegate.frontNavigationController pushViewController:chatViewConrtroller animated:YES];
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
    // tag = i + 100 + 1 - currentIndex
    // i = tag - 100 - 1 + currentIndex
    for (NSInteger i = self.currentProfileIndex; i < MIN(matchedProfilesArray.count, self.currentProfileIndex+3); i++)
    {
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-self.currentProfileIndex];
        [self setImageOnImageView:imageView WithActivityIndicator:nil WithImageURL:[matchedProfilesArray[i][@"oPic"] firstObject][@"url"] WithFBId:matchedProfilesArray[i][@"fbId"]];
        
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.profileTimer invalidate];
    self.profileTimer = nil;
    [super viewDidDisappear:animated];
}

@end
