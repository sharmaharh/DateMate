//
//  RecentChatsViewController.m
//  Dating
//
//  Created by Harsh Sharma on 8/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "RecentChatsViewController.h"
#import "ChatViewController.h"
#import "ChatPartners.h"
#import "ContactsViewController.h"

@interface RecentChatsViewController ()
{
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
    self.nameArray = [NSMutableArray array];
   
    [[MyWebSocket sharedInstance] connectSocketWithBlock:^(BOOL connected, NSError *error) {

        
        [[MyWebSocket sharedInstance] sendText:@{@"type" : @"login", @"userId" : [FacebookUtility sharedObject].fbID} acknowledge:^(NSDictionary *messageDict, NSError *error)
        {
            if (!error)
            {
                if ([[messageDict allKeys] containsObject:@"type"] && [messageDict objectForKey:@"type"])
                {
                    if ([[messageDict objectForKey:@"type"] isEqualToString:@"getProfileMatches"])
                    {
                        NSLog(@"Recent Chat response = %@",messageDict);
                        if ([messageDict[@"body"][@"likes"] count])
                        {
                            self.nameArray = [messageDict[@"body"][@"likes"] mutableCopy];
                            [self addRecentChatsToDatabase];
                        }
                        else
                        {
                            self.nameArray = [NSMutableArray array];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableViewRecentChats reloadData];
                        });
                        
                    }
                }
            }
                        
        }];
        
    }];
    
    if (self.isFromPush)
    {
        [self.navigationController pushViewController:[ChatViewController sharedChatInstance] animated:YES];
        return;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)getRecentChatUsers
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ChatPartners"];
    NSError *error = nil;
    self.nameArray = [NSMutableArray array];
    [self.tableViewRecentChats reloadData];
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
//    if ([results count] && ![Utils isInternetAvailable])
    if(0)
    {
        //Deal with Database
        
        for (ChatPartners *recentChats in results)
        {
            /*
             (
             {
             fName = Rahul;
             fbId = 752656701440251;
             flag = 5;
             "flag_state" = 2;
             ladt = "2014-10-12 07:44:26";
             pPic = "http://incredtechnologies.com/playground/ws/pics/xffgdf.jpg";
             },
             {
             fName = Navneet;
             fbId = 10203175848489479;
             flag = 5;
             "flag_state" = 2;
             ladt = "2014-10-12 07:43:11";
             pPic = "http://incredtechnologies.com/playground/ws/pics/262217_3991638541793_1099481420_n.jpg";
             }
             );
             */
            NSMutableDictionary *recentUserDict = [NSMutableDictionary dictionary];
            recentUserDict[@"fbId"] = recentChats.fbId;
            recentUserDict[@"fName"] = recentChats.fName;
            recentUserDict[@"ladt"] = recentChats.ladt;
            recentUserDict[@"pPic"] = recentChats.pPic_remote;
            recentUserDict[@"pPic_Local"] = recentChats.pPic_local;
            recentUserDict[@"unread_count"] = [NSString stringWithFormat:@"%@",recentChats.unreadCount];
            recentUserDict[@"totalChats_count"] = [NSString stringWithFormat:@"%@",recentChats.totalChatCount];
            recentUserDict[@"flag_state"] = [NSString stringWithFormat:@"%@",recentChats.chatCategory];
            recentUserDict[@"flag"] = [NSString stringWithFormat:@"%@",recentChats.chatStatus];
            recentUserDict[@"flag_initiate"] = [NSString stringWithFormat:@"%@",recentChats.chatFlagInitiate];
            [self.nameArray addObject:recentUserDict];
        }
        
        [self.tableViewRecentChats reloadData];
        
    }
    
    else
    {
        //Deal with Service
        
        
        AFNHelper *afnHelper = [AFNHelper new];
        [afnHelper getDataFromPath:@"getProfileMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID} mutableCopy] withBlock:^(id response, NSError *error)
         {
             if ([response[@"likes"] count])
             {
                 self.nameArray = response[@"likes"];
                 [self addRecentChatsToDatabase];
             }
             else
             {
                 self.nameArray = [NSMutableArray array];
             }
             [self.tableViewRecentChats reloadData];
             
         }];
    }
}

- (void)addRecentChatsToDatabase
{
    for (NSDictionary *dict in self.nameArray)
    {
        ChatPartners *recentChat = [NSEntityDescription insertNewObjectForEntityForName:@"ChatPartners" inManagedObjectContext:appDelegate.managedObjectContext];
        recentChat.unreadCount = [NSNumber numberWithInt:0];
        recentChat.fbId = dict[@"fbId"];
        recentChat.fName = dict[@"fName"];
        recentChat.ladt = dict[@"ladt"];
        recentChat.pPic_remote = dict[@"pPic"];
        recentChat.pPic_local = [self localPathForProfileImageWithRemoteURL:dict[@"pPic"]];
        recentChat.chatCategory = [NSNumber numberWithInt:[dict[@"flag_state"] intValue]];
        recentChat.chatStatus = [NSNumber numberWithInt:[dict[@"flag"] intValue]];
        recentChat.chatFlagInitiate = [NSNumber numberWithInt:[dict[@"flag_intiate"] intValue]];
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
    return [self.nameArray count];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.nameArray[indexPath.row][@"fName"];
    cell.detailTextLabel.text = self.nameArray[indexPath.row][@"unread_count"];
    cell.imageView.image = [UIImage imageNamed:@"Bubble-1"];
    cell.imageView.clipsToBounds = YES;
    [self setImageOnTableViewCell:cell AtIndexPath:indexPath];
    return cell;
}

- (void)setImageOnTableViewCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infoDict = self.nameArray[indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.nameArray count]>indexPath.row)
    {
        selectedIndex = indexPath.row;
        
        [self performSegueWithIdentifier:@"recentChatsToChatsIdentifier" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"recentChatsToChatsIdentifier"])
    {
        ChatViewController *chatViewController = [segue destinationViewController];
        chatViewController.userName = self.nameArray[selectedIndex][@"fName"];
        chatViewController.recieveFBID = self.nameArray[selectedIndex][@"fbId"];
        chatViewController.chatFlag = self.nameArray[selectedIndex][@"flag"];
        chatViewController.chatFlag_State = self.nameArray[selectedIndex][@"flag_state"];
        chatViewController.chatFlag_Initiate = self.nameArray[selectedIndex][@"flag_initiate"];
        chatViewController.chatFlag_Mine = self.nameArray[selectedIndex][@"flag_mine"];
        chatViewController.chatFlag_Mine_State = self.nameArray[selectedIndex][@"flag_mine_state"];
        [self resetBadgeCounterWithInfo:self.nameArray[selectedIndex]];
    }

}

- (void)resetBadgeCounterWithInfo:(NSDictionary *)infoDict
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ChatPartners"];
    NSPredicate *chatPredicate  = [NSPredicate predicateWithFormat:@"%K = %@",@"fbId",infoDict[@"fbId"]];
    
    [request setPredicate:chatPredicate];
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count])
    {
        ChatPartners *chatParterns = results[0];
        chatParterns.unreadCount = [NSNumber numberWithInt:0];
        [appDelegate.managedObjectContext save:nil];
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

- (IBAction)btnAllContactsPressed:(id)sender {
}
@end
