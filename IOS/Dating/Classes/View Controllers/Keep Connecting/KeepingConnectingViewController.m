//
//  KeepingConnectingViewController.m
//  Dating
//
//  Created by Harsh Sharma on 9/10/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "KeepingConnectingViewController.h"

@interface KeepingConnectingViewController ()
{
    NSMutableArray *notificationsArray;
    EMotionNotification emotionNotificaionType;
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [notificationsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [self setImageOnCell:cell onIndexPath:indexPath];
    cell.textLabel.text = notificationsArray[indexPath.row][@"fName"];
    cell.detailTextLabel.text = [self emotionStringByEmotionNotification:[notificationsArray[indexPath.row][@"flag"] intValue]];
    
    
    return cell;
}

- (void)setImageOnCell:(UITableViewCell *)cell onIndexPath:(NSIndexPath *)indexPath
{
    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:notificationsArray[indexPath.row][@"pPic"]]];
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

- (NSString *)emotionStringByEmotionNotification:(EMotionNotification)emotionNotificationType
{
    switch (emotionNotificationType)
    {
        case kWink:
            return @"Wink";
            
        case kStare:
            return @"Stare";
            
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
    [self.revealViewController revealToggle:self];
}

@end
