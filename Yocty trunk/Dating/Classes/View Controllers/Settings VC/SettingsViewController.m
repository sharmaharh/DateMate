//
//  SettingsViewController.m
//  Dating
//
//  Created by Harsh Sharma on 8/23/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
{
    NSArray *settingOptionsArray;
}
@end

@implementation SettingsViewController

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
   
    settingOptionsArray = @[@"Update Preferences",@"Notification", @"Sound"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -----
#pragma mark UITableViewDelegate & DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [settingOptionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = settingOptionsArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 1 || indexPath.row == 2)
    {
        UISwitch *settingsSwitch = [[UISwitch alloc] init];
        settingsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:(indexPath.row == 1)?@"Notification":@"Sound"];
        
        settingsSwitch.tag = indexPath.row;
        [settingsSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = settingsSwitch;
    }
    else
        cell.accessoryView = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            // Preferences
            [self performSegueWithIdentifier:@"SettingsToPreferencesIdentifier" sender:self];
            break;
            
        default:
            break;
    }
}

- (void)switchValueChanged:(UISwitch *)settingsSwitch
{
    if (settingsSwitch.tag == 1)
    {
        AFNHelper *afnhelper = [[AFNHelper alloc] init];
        [afnhelper getDataFromPath:@"updateSendNotification" withParamData:[@{@"ent_user_fbid" : [FacebookUtility sharedObject].fbID, @"ent_send_notify" : [NSString stringWithFormat:@"%i",(int)settingsSwitch.on + 1]} mutableCopy] withBlock:^(id response, NSError *error) {
            NSLog(@"Response  = %@",response);
            
        }];
        
        [[NSUserDefaults standardUserDefaults] setBool:settingsSwitch.on forKey:@"Notification"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:settingsSwitch.on forKey:@"Sound"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)logoutButtonPressed:(id)sender
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
        
    }
    else
    {
#if TARGET_IPHONE_SIMULATOR
        NSDictionary *reqDict = @{@"ent_sess_token": [[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"ent_dev_id":@"iPhone_Simulator"};
#else
        
        NSDictionary *reqDict = @{@"ent_sess_token": [[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"ent_dev_id":[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]};
        
#endif
        
        
        AFNHelper *afnHelper = [AFNHelper new];
        [afnHelper getDataFromPath:@"logout" withParamData:[reqDict mutableCopy] withBlock:^(id response, NSError *error) {
            if (!error)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fbID"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fbFullName"];
                appDelegate.userPreferencesDict = [NSMutableDictionary dictionary];
                [[NSUserDefaults standardUserDefaults] setObject:appDelegate.userPreferencesDict forKey:@"UserPreferences"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [FacebookUtility sharedObject].fbID = @"";
                [[FacebookUtility sharedObject] logOutFromFacebook];
                appDelegate.frontNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstNavigationController"];
                
                appDelegate.window.rootViewController = appDelegate.frontNavigationController;
                [appDelegate.window makeKeyAndVisible];
            }
            else
            {
                [Utils showOKAlertWithTitle:@"Dating" message:@"Unable to Logout, Please try Again."];
            }
            
        }];
    }
    
}

- (IBAction)deleteAccountButtonPressed:(id)sender
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {
#if TARGET_IPHONE_SIMULATOR
        NSDictionary *reqDict = @{@"ent_user_fbid": [FacebookUtility sharedObject].fbID};
#else
        
        NSDictionary *reqDict = @{@"ent_user_fbid": [FacebookUtility sharedObject].fbID};
        
#endif
        
        
        AFNHelper *afnHelper = [AFNHelper new];
        [afnHelper getDataFromPath:@"deleteAccount" withParamData:[reqDict mutableCopy] withBlock:^(id response, NSError *error) {
            if (!error)
            {
                [Utils showAlertView:_Alert_Title message:@"We hope you enjoyed it! Don't forget to come back again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fbID"];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fbFullName"];
                appDelegate.userPreferencesDict = [NSMutableDictionary dictionary];
                [[NSUserDefaults standardUserDefaults] setObject:appDelegate.userPreferencesDict forKey:@"UserPreferences"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [FacebookUtility sharedObject].fbID = @"";
                [[FacebookUtility sharedObject] logOutFromFacebook];
                appDelegate.frontNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstNavigationController"];
                
                appDelegate.window.rootViewController = appDelegate.frontNavigationController;
                [appDelegate.window makeKeyAndVisible];
            }
            else
            {
                [Utils showOKAlertWithTitle:@"Dating" message:@"Unable to Logout, Please try Again."];
            }
            
        }];
    }    
}


@end
