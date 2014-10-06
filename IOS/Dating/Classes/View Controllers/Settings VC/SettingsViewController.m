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
    settingOptionsArray = @[@"Preferences",@"Log Out",@"Option 3", @"Option 4", @"Option 5"];
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
    
    cell.textLabel.text = settingOptionsArray[indexPath.row];
    
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

- (IBAction)btnRevealPressed:(id)sender
{
    [self.revealViewController revealToggle:self];
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
