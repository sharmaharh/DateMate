//
//  KeepingConnectingViewController.m
//  Dating
//
//  Created by Harsh Sharma on 9/10/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "KeepingConnectingViewController.h"
#import "RecentChatsViewController.h"
#import "UserProfileDetailViewController.h"

@interface KeepingConnectingViewController ()
{
    NSMutableArray *notificationsArray;
    EMotionNotification emotionNotificaionType;
    NSArray                 *cellColors;
}
@end

@implementation KeepingConnectingViewController

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
    self.flabbyTableManager = [[BRFlabbyTableManager alloc] initWithTableView:self.tableViewPendingEmotions];
    [self.tableViewPendingEmotions setBackgroundColor:[UIColor clearColor]];
    cellColors = @[[UIColor colorWithRed:51.0f/255.0f green:147.0f/255.0f blue:228.0f/255.0f alpha:1.0f],
      [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f]];
    
    [self.flabbyTableManager setDelegate:self];
    
    [self  getPendingEmotionsNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPendingEmotionsNotifications
{
    notificationsArray = [NSMutableArray array];
    [[self.view viewWithTag:4] setHidden:YES];
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {
        [[Utils sharedInstance] startHSLoaderInView:self.view];
        
        AFNHelper *afnHelper = [AFNHelper new];
        [afnHelper getDataFromPath:@"getProfileMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID} mutableCopy] withBlock:^(id response, NSError *error)
         {
             
             if ([response[@"likes"] count])
             {
                 notificationsArray = [response[@"likes"] mutableCopy];
                 [self filterLikedByBothInNotificationsArray];
                 [self.tableViewPendingEmotions reloadData];
             }
             else
             {
                 [self showError];
             }
             [[Utils sharedInstance] stopHSLoader];
         }];
    }
    
}

- (void)filterLikedByBothInNotificationsArray
{
    NSArray *tempArray = [notificationsArray copy];
    
    for (NSDictionary *dict in tempArray)
    {
        if ([dict[@"flag"] isEqualToString:@"5"])
        {
            [notificationsArray removeObject:dict];
        }
    }
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


#pragma mark -----
#pragma mark UITableViewDelegate & DataSource

- (UIColor *)flabbyTableManager:(BRFlabbyTableManager *)tableManager flabbyColorForIndexPath:(NSIndexPath *)indexPath{
    
    return cellColors[indexPath.row%notificationsArray.count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    return [notificationsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BRFlabbyTableViewCellIdentifier";
    BRFlabbyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIImageView *profileImageView = (UIImageView *)[cell.contentView viewWithTag:1];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2;
    profileImageView.layer.borderColor = ((UIColor *)(cellColors[(indexPath.row+1)%cellColors.count])).CGColor;
    profileImageView.layer.borderWidth = 0.5f;
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:2];
    [self setImageOnImageView:profileImageView WithActivityIndicator:activityIndicator onIndexPath:indexPath];
    
    UILabel *userName = (UILabel *)[cell.contentView viewWithTag:3];
    userName.text = notificationsArray[indexPath.row][@"fName"];
    userName.textColor = cellColors[(indexPath.row+1)%cellColors.count];
    
    if (!cell.accessoryView)
    {
        UIButton *stareBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        stareBackBtn.frame = CGRectMake(0, 0, 80, 30);
        stareBackBtn.titleLabel.font = [UIFont fontWithName:@"SegoeUI" size:14];
        stareBackBtn.layer.borderWidth = 1.0f;
        [stareBackBtn setTitle:@"Stare Back" forState:UIControlStateNormal];
        [stareBackBtn addTarget:self action:@selector(stareBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell setAccessoryView:stareBackBtn];
    }
    
    [(UIButton *)cell.accessoryView setTitleColor:cellColors[(indexPath.row+1)%cellColors.count] forState:UIControlStateNormal];
    cell.accessoryView.layer.cornerRadius = cell.accessoryView.frame.size.height/2;
    cell.accessoryView.layer.borderColor = ((UIColor *)(cellColors[(indexPath.row+1)%cellColors.count])).CGColor;
    cell.accessoryView.accessibilityIdentifier = [NSString stringWithFormat:@"%li",(long)indexPath.row];
    
    [cell setFlabby:YES];
    [cell setLongPressAnimated:YES];
    [cell setFlabbyColor:cellColors[indexPath.row%cellColors.count]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setUserInteractionEnabled:NO];
    [[Utils sharedInstance] startHSLoaderInView:self.view];
    
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"getProfile" withParamData:[@{@"ent_user_fbid": notificationsArray[indexPath.row][@"fbId"]} mutableCopy] withBlock:^(id response, NSError *error)
     {
         [cell setUserInteractionEnabled:YES];
         [[Utils sharedInstance] stopHSLoader];
         
         if ([response[@"matches"] count])
         {
             UserProfileDetailViewController *userProfileDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileDetailViewController"];
             userProfileDetailViewController.matchedProfilesArray = [response[@"matches"] mutableCopy];
             [self clubProfileImageInMainArray:userProfileDetailViewController.matchedProfilesArray];
             userProfileDetailViewController.currentProfileIndex = 0;
             userProfileDetailViewController.isFromMatches = NO;
             [self.navigationController pushViewController:userProfileDetailViewController animated:YES];
         }
         else
         {
             [Utils showOKAlertWithTitle:_Alert_Title message:@"Unable to fetch profile info."];
         }
     }];
}

- (void)clubProfileImageInMainArray:(NSMutableArray *)matchedProfilesArray
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

- (void)setImageOnImageView:(UIImageView *)profileImageView WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator onIndexPath:(NSIndexPath *)indexPath
{
    NSString *ImageURL = notificationsArray[indexPath.row][@"pPic"];
    
    [profileImageView setContentMode:UIViewContentModeCenter];
    [activityIndicator startAnimating];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:ImageURL withFBID:notificationsArray[indexPath.row][@"fbId"] withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        [activityIndicator stopAnimating];
        
        if (!error)
        {
            [profileImageView setImage:[Utils scaleImage:image WithRespectToFrame:profileImageView.frame]];
        }
        else
        {
            [profileImageView setImage:[UIImage imageNamed:@"Bubble-0"]];
        }
        
    }];

}

- (void)stareBackButtonPressed:(UIButton *)stareBtn
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {
        AFNHelper *afnhelper = [AFNHelper new];
        
        [[Utils sharedInstance] startHSLoaderInView:self.view];
        
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,notificationsArray[[stareBtn.accessibilityIdentifier intValue]][@"fbId"],@"1"] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
        
        [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
         {
             [[Utils sharedInstance] stopHSLoader];
             
             if (!error)
             {
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [notificationsArray removeObjectAtIndex:[stareBtn.accessibilityIdentifier intValue]];
                     [self.tableViewPendingEmotions deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[stareBtn.accessibilityIdentifier intValue] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
                              [appDelegate.frontNavigationController setNavigationBarHidden:YES animated:YES];
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
                     //                     [Utils showOKAlertWithTitle:@"Dating" message:response[@"errMsg"]];
                     [self.lblRequestSent setText:[NSString stringWithFormat:@"You Stared back at %@",notificationsArray[[stareBtn.accessibilityIdentifier intValue]][@"firstName"]]];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.viewRequestSent setHidden:NO];
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self.viewRequestSent setHidden:YES];
                         });
                     });
                     
                 }
                 
                 
             }
             else
             {
                 [Utils showOKAlertWithTitle:_Alert_Title message:@"Error Occured, Please Try Again"];
                 
             }
             
         }];
    }
}

- (void)showError
{
    UIView *errorMsgView = (UIView *)[self.view viewWithTag:4];
    [errorMsgView setHidden:NO];
    [[Utils sharedInstance] stopHSLoader];
}

-(void)dealloc
{
    [self.flabbyTableManager removeObservers];
}

@end
