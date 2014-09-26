//
//  FindMatchViewController.m
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "FindMatchViewController.h"
#import "RecentChatsViewController.h"

@interface FindMatchViewController ()
{
    NSArray *matchedProfilesArray;
    NSInteger currentIndex;
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self findMatchesList];
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileOnLayout
{
    NSDictionary *profileDict = matchedProfilesArray[currentIndex];
    for (int i = 1; i < 4; i++)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.selected = NO;
    }
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    [self.profileImageView setImage:nil];
    [self.activityIndicator startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileDict[@"pPic"][0][@"pImg"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self.activityIndicator stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!connectionError)
        {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.profileImageView setImage:image];
            }
            
        }
        else
        {
            [Utils showOKAlertWithTitle:@"Dating" message:@"Some Error Occured, Please Try Again."];
        }
    }];
    
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

- (void)findMatchesList
{
    matchedProfilesArray = [NSMutableArray array];
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        [self.activityIndicator startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"findMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID} mutableCopy] withBlock:^(id response, NSError *error)
         {
             [self.activityIndicator stopAnimating];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             if (![[response objectForKey:@"errFlag"] boolValue])
             {
                 if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
                 {
                     matchedProfilesArray = [response objectForKey:@"matches"];
                     if ([matchedProfilesArray count])
                     {
                         [self setProfileOnLayout];
                         for (UIView *view in self.view.subviews)
                         {
                             [view setHidden:NO];
                         }
                         UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                         [errorMsgLabel setHidden:YES];
                     }
                     else
                     {
                         for (UIView *view in self.view.subviews)
                         {
                             [view setHidden:YES];
                         }
                         UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                         [errorMsgLabel setHidden:NO];
                     }
                     
                 }
                 else
                 {
                     matchedProfilesArray = [NSMutableArray array];
                     for (UIView *view in self.view.subviews)
                     {
                         [view setHidden:YES];
                     }
                     UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                     [errorMsgLabel setHidden:NO];
                 }
             }
             else
             {
                 for (UIView *view in self.view.subviews)
                 {
                     [view setHidden:YES];
                 }
                 UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                 [errorMsgLabel setHidden:NO];
             }
             
         }];
    }

}

- (IBAction)passProfileButtonPressed:(id)sender
{
    currentIndex++;
    if (currentIndex < matchedProfilesArray.count)
    {
        [self setProfileOnLayout];
    }
    else
    {
        
        for (UIView *view in self.view.subviews)
        {
            [view setHidden:YES];
        }
        UILabel *errorLabel = (UILabel *)[self.view viewWithTag:100];
        [errorLabel setHidden:NO];
        
//        [Utils showOKAlertWithTitle:@"Dating" message:@"Sorry, Boss No More Entry Available"];
    }
    
}

- (IBAction)passEmotionsButtonPressed:(id)sender
{
    UIButton *emotionsButton = (UIButton *)sender;
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        AFNHelper *afnhelper = [AFNHelper new];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[currentIndex][@"fbId"],[NSString stringWithFormat:@"%i",emotionsButton.tag]] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
        
        [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 [self passProfileButtonPressed:nil];
                 
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
                             [appDelegate.revealController pushFrontViewController:appDelegate.frontNavigationController animated:NO];
                             ChatViewController *chatViewConrtroller = [ChatViewController sharedChatInstance];
                             chatViewConrtroller.recieveFBID = response[@"uFbId"];
                             chatViewConrtroller.userName = response[@"uName"];
                             [appDelegate.frontNavigationController pushViewController:chatViewConrtroller animated:YES];
                         }
                         
                     }];
                     
                 }
                 else
                 {
                     [Utils showOKAlertWithTitle:@"Dating" message:response[@"errMsg"]];
                 }
                 
                 
             }
             else
             {
                 [Utils showOKAlertWithTitle:@"Dating" message:@"Error Occured, Please Try Again"];
             }
             
             //         emotionsButton.selected = YES;
             
             //         if ([[response objectForKey:@"errFlag"] boolValue])
             //         {
             //             if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
             //             {
             //                 matchedProfilesArray = [response objectForKey:@"matches"];
             //                 [self setProfileOnLayout];
             //             }
             //             else
             //             {
             //                 matchedProfilesArray = [NSMutableArray array];
             //             }
             //         }
             
         }];
    }
    
}
- (IBAction)btnRevealPressed:(id)sender
{
    [self.revealViewController revealToggle:self];
}
@end
