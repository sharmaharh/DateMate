//
//  RearMenuViewController.m
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "RearMenuViewController.h"
#import "RecentChatsViewController.h"
#import "KeepingConnectingViewController.h"
#import "UserProfileViewController.h"

@interface RearMenuViewController ()
{
    NSArray *arrOptions;
    NSArray *arrImages;
}
@end

@implementation RearMenuViewController

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
    arrImages = @[@"message_icon",@"preference_icon",@"pendingrequest_icon",@"setting_icon",@"profile_icon"];
    arrOptions = @[@"Profile", @"Keep Connecting", @"Pending Emotions", @"Chats", @"Settings"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.rowHeight = 48;
    return [arrOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 2)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        
    }
    else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:arrImages[indexPath.row]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = arrOptions[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // We know the frontViewController is a NavigationController
    UINavigationController *frontNavigationController = (id)appDelegate.revealController.contentViewController;  // <-- we know it is a NavigationController
    NSInteger row = indexPath.row;
    
	// Here you'd implement some of your own logic... I simply take for granted that the first row (=0) corresponds to the "FrontViewController".
    
    switch (row) {
        case 0:
            // Profile
            if (![frontNavigationController.topViewController isKindOfClass:[UserProfileViewController class]] )
            {
                
                UserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userProfileViewController];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
            }
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            
            [appDelegate.revealController hideMenuViewController];

            break;
            
        case 1:
        {
            // Find Matches
            if ( ![frontNavigationController.topViewController isKindOfClass:[FindMatchViewController class]] )
            {
                
                FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
            }
            // Seems the user attempts to 'switch' to exactly the same controller he came from!

            [appDelegate.revealController hideMenuViewController];

        }
            break;
            
        case 2:
            // Pending Emotions
            if ( ![frontNavigationController.topViewController isKindOfClass:[KeepingConnectingViewController class]] )
            {
                KeepingConnectingViewController *keepConnectingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KeepingConnectingViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:keepConnectingViewController];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
            }

            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            [appDelegate.revealController hideMenuViewController];

            break;
            
        case 3:
            // Chat
            if ( ![frontNavigationController.topViewController isKindOfClass:[RecentChatsViewController class]] )
            {
                RecentChatsViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
            }
            
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            [appDelegate.revealController hideMenuViewController];
            break;
            
        case 4:
            // Settings
            if ( ![frontNavigationController.topViewController isKindOfClass:[SettingsViewController class]] )
            {
                SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
            }

            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            [appDelegate.revealController hideMenuViewController];
            break;
            
        default:
            break;
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

@end
