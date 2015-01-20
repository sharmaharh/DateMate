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
    settingOptionsArray = @[@"Preferences",@"Log Out",@"Notification", @"Sound"];
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
    return [settingOptionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = settingOptionsArray[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row > 1)
    {
        UISwitch *settingsSwitch = [[UISwitch alloc] init];
        settingsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:(indexPath.row == 2)?@"Notification":@"Sound"];
        
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
            
        case 1:
            [self logout];
            break;
            
        case 2:
            
            break;
            
        case 3:
            
            break;
            
        default:
            break;
    }
}

- (void)switchValueChanged:(UISwitch *)settingsSwitch
{
    if (settingsSwitch.tag == 2)
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

- (void)logout
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
