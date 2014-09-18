//
//  RecentChatsViewController.m
//  Dating
//
//  Created by Harsh Sharma on 8/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "RecentChatsViewController.h"
#import "ChatViewController.h"
#import "RecentChats.h"

@interface RecentChatsViewController ()
{
    NSMutableArray *nameArray;
    NSInteger selectedIndex;
}
@end

@implementation RecentChatsViewController

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
    nameArray = [NSMutableArray array];
    if (self.isFromPush)
    {
        [self.navigationController pushViewController:[ChatViewController sharedChatInstance] animated:YES];
        return;
    }
    [self getRecentChatUsers];
}

- (void)getRecentChatUsers
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"RecentChats"];
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([results count] || ![Utils isInternetAvailable])
    {
        //Deal with Database
        
        for (RecentChats *recentChats in results)
        {
            /*
             [
             {
             "fbId": "661762160568643",
             "fName": "Harsh",
             "ladt": "2014-09-12 03: 20: 48",
             "pPic": "https: \/\/fbcdn-profile-a.akamaihd.net\/hprofile-ak-xpa1\/v\/t1.0-1\/c0.0.50.50\/p50x50\/6417_608575192554007_3093356137364336146_n.jpg?oh=2386e29e43cf7373c15476fd4c4f2c32&oe=548C4D97&__gda__=1419147389_3fc86889e61d8a861c6a3025e9106b59",
             "flag": "5"
             }
             ]
             */
            NSMutableDictionary *recentUserDict = [NSMutableDictionary dictionary];
            recentUserDict[@"fbId"] = recentChats.fbId;
            recentUserDict[@"fName"] = recentChats.fName;
            recentUserDict[@"ladt"] = recentChats.ladt;
            recentUserDict[@"pPic"] = recentChats.pPic_remote;
            recentUserDict[@"pPic_Local"] = recentChats.pPic_local;
            [nameArray addObject:recentUserDict];
        }
        
        [self.tableViewRecentChats reloadData];
        
    }
    
    else
    {
        //Deal with Service
        AFNHelper *afnHelper = [AFNHelper new];
        [afnHelper getDataFromPath:@"getProfileMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_user_action": @"5"} mutableCopy] withBlock:^(id response, NSError *error)
         {
             if ([response[@"likes"] count])
             {
                 nameArray = response[@"likes"];
                 [self addRecentChatsToDatabase];
             }
             else
             {
                 nameArray = [NSMutableArray array];
             }
             [self.tableViewRecentChats reloadData];
             
         }];
    }
    
    
}

- (void)addRecentChatsToDatabase
{
    for (NSDictionary *dict in nameArray)
    {
        RecentChats *recentChat = [NSEntityDescription insertNewObjectForEntityForName:@"RecentChats" inManagedObjectContext:appDelegate.managedObjectContext];
        recentChat.unreadCount = [NSNumber numberWithInt:0];
        recentChat.fbId = dict[@"fbId"];
        recentChat.fName = dict[@"fName"];
        recentChat.ladt = dict[@"ladt"];
        recentChat.pPic_remote = dict[@"pPic"];
        recentChat.pPic_local = [self localPathForProfileImageWithRemoteURL:dict[@"pPic"]];
        
        [appDelegate.managedObjectContext save:nil];
        
    }
}

- (NSString *)localPathForProfileImageWithRemoteURL:(NSString *)pPicURL
{
    NSString *localpath = @"";
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    localpath = [documentsDirectory stringByAppendingPathComponent:@"Profile_Images"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localpath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:localpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localpath = [localpath stringByAppendingPathComponent:[pPicURL lastPathComponent]];
    [self downloadProfileImageToURLPath:localpath FromRemotePath:pPicURL];
    return localpath;
}

- (void)downloadProfileImageToURLPath:(NSString *)localPath FromRemotePath:(NSString *)remotePath
{
    if ([Utils isInternetAvailable])
    {
        NSURLRequest *imageURLReq = [NSURLRequest requestWithURL:[NSURL URLWithString:remotePath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
        
        [NSURLConnection sendAsynchronousRequest:imageURLReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError)
            {
                UIImage *profileImage = [UIImage imageWithData:data];
                if (profileImage)
                {
                    [[NSFileManager defaultManager] createFileAtPath:localPath contents:data attributes:nil];
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----
#pragma mark UITableViewDelegate & DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nameArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = nameArray[indexPath.row][@"fName"];
    cell.detailTextLabel.text = @"Last Message to be seen here";
    cell.imageView.image = [UIImage imageNamed:@"Bubble-1"];
    cell.imageView.clipsToBounds = YES;
    [self setImageOnTableViewCell:cell AtIndexPath:indexPath];
    return cell;
}

- (void)setImageOnTableViewCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infoDict = nameArray[indexPath.row];
    if ([[infoDict allKeys] containsObject:@"pPic_Local"])
    {
        UIImage *cellImage = [UIImage imageWithContentsOfFile:infoDict[@"pPic_Local"]];
        if (cellImage)
        {
            cell.imageView.image = cellImage;
        }
        else
        {
            [self downloadImageFromURL:infoDict[@"pPic"] onCell:cell];
        }
    }
    else
    {
        [self downloadImageFromURL:infoDict[@"pPic"] onCell:cell];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"recentChatsToChatsIdentifier" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *chatViewController = [segue destinationViewController];
    chatViewController.userName = nameArray[selectedIndex][@"fName"];
    chatViewController.recieveFBID = nameArray[selectedIndex][@"fbId"];
}

- (void)downloadImageFromURL:(NSString *)imageURL onCell:(UITableViewCell *)cell
{
    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnRevealPressed:(id)sender
{
    [self.revealViewController revealToggle:self];
}
@end
