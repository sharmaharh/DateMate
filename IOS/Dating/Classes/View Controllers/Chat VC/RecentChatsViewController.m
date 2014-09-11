//
//  RecentChatsViewController.m
//  Dating
//
//  Created by Harsh Sharma on 8/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "RecentChatsViewController.h"
#import "ChatViewController.h"

@interface RecentChatsViewController ()
{
    NSArray *nameArray;
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
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"getProfileMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_user_action": @"5"} mutableCopy] withBlock:^(id response, NSError *error)
    {
        if ([response[@"likes"] count])
        {
            nameArray = response[@"likes"];
        }
        else
        {
            nameArray = [NSMutableArray array];
        }
        [self.tableViewRecentChats reloadData];
        
    }];
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
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Bubble-%i",indexPath.row]];
    cell.imageView.clipsToBounds = YES;
    [self setImageOnTableViewCell:cell AtIndexPath:indexPath];
    return cell;
}

- (void)setImageOnTableViewCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    
    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:nameArray[indexPath.row][@"pPic"]]];
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
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"recentChatsToChatsIdentifier" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *chatViewController = [segue destinationViewController];
    chatViewController.userName = nameArray[selectedIndex];
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
