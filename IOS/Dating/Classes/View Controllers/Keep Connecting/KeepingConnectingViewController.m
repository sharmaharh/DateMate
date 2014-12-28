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
    if ([notificationsArray count]) {
        return 20;
    }
    return 0;
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
//    [self setImageOnCell:cell onIndexPath:indexPath];
    cell.textLabel.text = notificationsArray[indexPath.row%notificationsArray.count][@"fName"];
//    cell.textLabel.text = @"Harsh Sharma";
    cell.detailTextLabel.text = [self emotionStringByEmotionNotification:[notificationsArray[indexPath.row%notificationsArray.count][@"flag"] intValue]];
//    cell.detailTextLabel.text = @"Stared";
    [cell setFlabby:YES];
    [cell setLongPressAnimated:YES];
    [cell setFlabbyColor:cellColors[indexPath.row%cellColors.count]];
    return cell;
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    if (!cell)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    }
//    
//    
//    
//    
//    return cell;
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
}

-(void)dealloc
{
    [self.flabbyTableManager removeObservers];
}

@end
