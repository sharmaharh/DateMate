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
    
    [self.tableViewPendingEmotions registerClass:[BRFlabbyTableViewCell class] forCellReuseIdentifier:@"BRFlabbyTableViewCellIdentifier"];
    
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
            [Utils showOKAlertWithTitle:@"Dating" message:@"No Pending Notification found."];
        }
    }];
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
    tableView.rowHeight = 70;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    return [notificationsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"BRFlabbyTableViewCellIdentifier";
    BRFlabbyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[BRFlabbyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [self setImageOnCell:cell onIndexPath:indexPath];
    cell.textLabel.text = notificationsArray[indexPath.row%notificationsArray.count][@"fName"];
    cell.detailTextLabel.text = [self emotionStringByEmotionNotification:[notificationsArray[indexPath.row%notificationsArray.count][@"flag"] intValue]];
    [cell setFlabby:YES];
    [cell setLongPressAnimated:YES];
    [cell setFlabbyColor:cellColors[indexPath.row%cellColors.count]];
    
    UIButton *stareBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stareBackBtn setFrame:CGRectMake(0, 0, 80, 44)];
    stareBackBtn.tag = indexPath.row;
    [stareBackBtn setTitleColor:cellColors[(indexPath.row+1)%cellColors.count] forState:UIControlStateNormal];
    [stareBackBtn addTarget:self action:@selector(stareBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [stareBackBtn setBackgroundColor:[UIColor yellowColor]];
    
    [cell setAccessoryView:stareBackBtn];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"getProfile" withParamData:[@{@"ent_user_fbid": notificationsArray[indexPath.row][@"fbId"]} mutableCopy] withBlock:^(id response, NSError *error)
     {
         if ([response[@"matches"] count])
         {
             UserProfileDetailViewController *userProfileDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileDetailViewController"];
             userProfileDetailViewController.matchedProfilesArray = response[@"matches"];
             userProfileDetailViewController.currentProfileIndex = 0;
         }
         else
         {
             [Utils showOKAlertWithTitle:_Alert_Title message:@"Unable to fetch profile info."];
         }
     }];
}

- (void)setImageOnCell:(UITableViewCell *)cell onIndexPath:(NSIndexPath *)indexPath
{
    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:notificationsArray[indexPath.row%notificationsArray.count][@"pPic"]]];
    [NSURLConnection sendAsynchronousRequest:imageURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (!connectionError)
         {
             UIImage *cellImage = [UIImage imageWithData:data];
             if (cellImage)
             {
                 cell.imageView.image = cellImage;
             }
         }
     }];
    
}

- (void)stareBackButtonPressed:(UIButton *)stareBtn
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
//        AFNHelper *afnhelper = [AFNHelper new];
//        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[currentProfileIndex][@"fbId"],@"1"] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
//        
//        [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
//         {
//             if (!error)
//             {
//                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                     [self.tableViewPendingEmotions deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:stareBtn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                 });
//                 
//                 
//                 if ([response[@"errMsg"] isEqualToString:@"Congrats! You got a match"]) {
//                     // Now Winked Back, Start Conversation
//                     [[Utils sharedInstance] openAlertViewWithTitle:@"Dating" message:response[@"errMsg"] buttons:@[@"Cancel",@"Chat"] completion:^(UIAlertView *alert, NSInteger buttonIndex)
//                      {
//                          if (buttonIndex)
//                          {
//                              
//                              UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                              RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
//                              appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
//                              recentChatViewController.isFromPush = NO;
//                              [appDelegate.revealController setContentViewController:appDelegate.frontNavigationController animated:NO];
//                              ChatViewController *chatViewConrtroller = [ChatViewController sharedChatInstance];
//                              chatViewConrtroller.recieveFBID = response[@"uFbId"];
//                              chatViewConrtroller.userName = response[@"uName"];
//                              [appDelegate.frontNavigationController pushViewController:chatViewConrtroller animated:YES];
//                          }
//                          
//                      }];
//                     
//                 }
//                 else
//                 {
//                     //                     [Utils showOKAlertWithTitle:@"Dating" message:response[@"errMsg"]];
//                     [self.lblRequestSent setText:[NSString stringWithFormat:@"You Stared at %@",matchedProfilesArray[currentProfileIndex][@"firstName"]]];
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         [self.viewRequestSent setHidden:NO];
//                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                             [self.viewRequestSent setHidden:YES];
//                         });
//                     });
//                     
//                 }
//                 
//                 
//             }
//             else
//             {
//                 [Utils showOKAlertWithTitle:@"Dating" message:@"Error Occured, Please Try Again"];
//             }
//             
//         }];
    }
}

- (NSString *)emotionStringByEmotionNotification:(EMotionNotification)emotionNotificationType
{
    switch (emotionNotificationType)
    {
        case kWink:
            return @"Wink";
            
        case kStare:
            return @"Stare Back";
            
        case kWave:
            return @"Wave";
            
        case kSmile:
            return @"Smile";
            
        case kLikedByBoth:
            return @"Liked By Both";
            
        case kDisliked:
            return @"Disliked";
            
        case kBlocked:
            return @"Blocked";
            
        default:
            return @"";
    }
}

- (IBAction)btnRevealPressed:(id)sender
{
}

-(void)dealloc
{
    [self.flabbyTableManager removeObservers];
}

@end
