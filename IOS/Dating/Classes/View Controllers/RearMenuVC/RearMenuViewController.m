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
    [self.proflePicImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [Utils configureLayerForHexagonWithView:self.proflePicImageView withBorderColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6] WithCornerRadius:20 WithLineWidth:3 withPathColor:[UIColor clearColor]];
}

- (void)setImageOnButton:(UIImageView *)imgView WithImageURL:(NSString *)ImageURL
{
    if (!ImageURL || !ImageURL.length) {
        return;
    }
    __block NSString *bigImageURLString = ImageURL;
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    
    NSString *dirPath = [self ProfileImageFolderPath];
    NSString *filePath = [dirPath stringByAppendingPathComponent:[ImageURL lastPathComponent]];
    
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (image)
        {
            [imgView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [self setImageOnButton:imgView WithImageURL:ImageURL];
        }
        
    }
    else
    {
        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
            
            
            __block NSData *imageData = nil;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error)
             {
                 if (!error)
                 {
                     imageData = data;
                     UIImage *image = nil;
                     data = nil;
                     image = [UIImage imageWithData:imageData];
                     if (image == nil)
                     {
                         image = [UIImage imageNamed:@"Bubble-0"];
                     }
                     
                     [imgView setImage:image];
                     
                     // Write Image in Document Directory
                     int64_t delayInSeconds = 0.4;
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                     
                     
                     dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
                         if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                         {
                             if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
                             {
                                 [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
                             }
                             
                             [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
                             imageData = nil;
                         }
                     });
                 }
                 
             }];
            
            bigImageURLString = nil;
            
            
        });
    }
    
}


- (NSString *)ProfileImageFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Profile_Images"];
    basePath = [basePath stringByAppendingPathComponent:[FacebookUtility sharedObject].fbID];
    return basePath;
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
    NSInteger row = indexPath.row;
    
	// Here you'd implement some of your own logic... I simply take for granted that the first row (=0) corresponds to the "FrontViewController".
    
    switch (row) {
        case 0:
            // Profile
            if (![frontNavigationController.topViewController isKindOfClass:[UserProfileViewController class]] )
            {
                
                UserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userProfileViewController];
                [navigationController setNavigationBarHidden:YES];
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
                [navigationController setNavigationBarHidden:YES];
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
                [navigationController setNavigationBarHidden:YES];
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
                [navigationController setNavigationBarHidden:YES];
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
                [navigationController setNavigationBarHidden:YES];
                [appDelegate.revealController setContentViewController:navigationController animated:YES];
            }

            // Seems the user attempts to 'switch' to exactly the same controller he came from!
            [appDelegate.revealController hideMenuViewController];
            break;
            
        default:
            break;
    }
	
}

@end
