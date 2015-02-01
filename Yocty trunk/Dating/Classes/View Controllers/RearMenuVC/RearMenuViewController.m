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
    arrImages = @[@"profile_icon",@"message_icon",@"preference_icon",@"pendingrequest_icon",@"setting_icon",];
    arrOptions = @[@"Profile", @"Keep Connecting", @"Pending Emotions", @"Chats", @"Settings"];
    
    NSString *imgURLString = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ProfileImages"] firstObject];
    
    [self setImageOnButton:self.proflePicImageView WithImageURL:imgURLString];
    [self.lblUsername setText:[FacebookUtility sharedObject].fbFullName];
    [Utils configureLayerForHexagonWithView:self.proflePicImageView withBorderColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6] WithCornerRadius:20 WithLineWidth:3 withPathColor:[UIColor clearColor]];
}

- (void)setImageOnButton:(UIImageView *)imgView WithImageURL:(NSString *)ImageURL
{
    [imgView setContentMode:UIViewContentModeCenter];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:ImageURL withFBID:[FacebookUtility sharedObject].fbID withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        
        if (!error)
        {
            [imgView setImage:[Utils scaleImage:image WithRespectToFrame:imgView.frame]];
        }
        else
        {
            [imgView setImage:[UIImage imageNamed:@"Bubble-0"]];
        }
    }];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    UIViewController *topController = frontNavigationController.topViewController;
    NSInteger row = indexPath.row;
    
	// Here you'd implement some of your own logic... I simply take for granted that the first row (=0) corresponds to the "FrontViewController".
    
    switch (row) {
        case 0:
            // Profile
            if (![topController isKindOfClass:[UserProfileViewController class]] )
            {
                
                UserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userProfileViewController];
                [navigationController setNavigationBarHidden:YES];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
                [[MyWebSocket sharedInstance] logOutUser];
            }
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            
            [appDelegate.revealController hideMenuViewController];

            break;
            
        case 1:
        {
            // Find Matches
            if ( ![topController isKindOfClass:[FindMatchViewController class]] )
            {
                
                FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
                [navigationController setNavigationBarHidden:YES];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
                [[MyWebSocket sharedInstance] logOutUser];
            }
            else
            {
                FindMatchViewController *findMatchViewController =  (FindMatchViewController *)((UINavigationController *)appDelegate.revealController.contentViewController).topViewController;
                [findMatchViewController findMatchesList];
                [[MyWebSocket sharedInstance] logOutUser];
            }
            // Seems the user attempts to 'switch' to exactly the same controller he came from!

            [appDelegate.revealController hideMenuViewController];

        }
            break;
            
        case 2:
            // Pending Emotions
            if ( ![topController isKindOfClass:[KeepingConnectingViewController class]] )
            {
                KeepingConnectingViewController *keepConnectingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KeepingConnectingViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:keepConnectingViewController];
                [navigationController setNavigationBarHidden:YES];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
                [[MyWebSocket sharedInstance] logOutUser];
            }

            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            [appDelegate.revealController hideMenuViewController];

            break;
            
        case 3:
            // Chat
            if ( ![topController isKindOfClass:[RecentChatsViewController class]] )
            {
                RecentChatsViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
                [navigationController setNavigationBarHidden:YES];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
            }
            
            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            [appDelegate.revealController hideMenuViewController];
            break;
            
        case 4:
            // Settings
            if ( ![topController isKindOfClass:[SettingsViewController class]] )
            {
                SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
                [navigationController setNavigationBarHidden:YES];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
                [[MyWebSocket sharedInstance] logOutUser];
            }

            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            [appDelegate.revealController hideMenuViewController];
            break;
            
        default:
            break;
    }
    topController = nil;
    frontNavigationController = nil;
}

@end
