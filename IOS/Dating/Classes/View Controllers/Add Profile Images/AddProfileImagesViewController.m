//
//  AddProfileImagesViewController.m
//  Dating
//
//  Created by Harsh Sharma on 9/24/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "AddProfileImagesViewController.h"
#import "FindMatchViewController.h"
#import "RearMenuViewController.h"
#import "UserProfileViewController.h"

@interface AddProfileImagesViewController ()

@end

@implementation AddProfileImagesViewController

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
    [[NSUserDefaults standardUserDefaults] setObject:self.profileImagesArray forKey:@"ProfileImages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setProfileImagesOnButtons];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileImagesOnButtons
{
    for (int i = 0 ; i < self.profileImagesArray.count; i++)
    {
        [self setImageWithButtonIndex:i+1];
    }
}

- (void)setImageOnButton:(UIButton *)btn WithURL:(NSString *)imageURL WithProgressIndicator:(UIActivityIndicatorView *)activityIndicator
{
    if (!imageURL || !imageURL.length) {
        return;
    }
    __block NSString *bigImageURLString = imageURL;
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    
    NSString *dirPath = [self ProfileImageFolderPath];
    NSString *filePath = [dirPath stringByAppendingPathComponent:[imageURL lastPathComponent]];
    
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (image)
        {
            [btn setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]] forState:UIControlStateNormal];
            
            [activityIndicator stopAnimating];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [self setImageOnButton:btn WithURL:imageURL WithProgressIndicator:activityIndicator];
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
                    
                    [btn setImage:image forState:UIControlStateNormal];
                    [activityIndicator stopAnimating];
                    
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

- (void)setImageWithButtonIndex:(NSInteger)btnIndex
{
    NSString *imgURLString = self.profileImagesArray[btnIndex-1];
    if (!imgURLString || !imgURLString.length) {
        return;
    }
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    NSString *dirPath = [self ProfileImageFolderPath];
    __block NSString *filePath = [dirPath stringByAppendingPathComponent:[imgURLString lastPathComponent]];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:btnIndex+10];
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:btnIndex];
        [btn setImage:[UIImage imageWithContentsOfFile:filePath] forState:UIControlStateNormal];
        [activityIndicator stopAnimating];
    }
    else
    {
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imgURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
        
        [activityIndicator startAnimating];
        [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             [activityIndicator stopAnimating];
             if (!connectionError)
             {
                 UIImage *image = [UIImage imageWithData:data];
                 if (image)
                 {
                     NSInteger btnIndex = [self.profileImagesArray indexOfObject:[response.URL absoluteString]]+1;
                     filePath = [dirPath stringByAppendingPathComponent:[[response.URL absoluteString] lastPathComponent]];
//                     [self.profileImagesArray replaceObjectAtIndex:btnIndex-1 withObject:image];
                     UIButton *btn = (UIButton *)[self.view viewWithTag:btnIndex];
                     [btn setImage:image forState:UIControlStateNormal];
                     [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
                     
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
                             
                             [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
                         }
                     });
                 }
             }
             
         }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnEditPressed:(id)sender
{
    UserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.imagesArray = self.profileImagesArray;
    appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:userProfileViewController];
    
    RearMenuViewController *rearMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
    appDelegate.revealController = [[ResideMenuViewController alloc] initWithContentViewController:appDelegate.frontNavigationController leftMenuViewController:rearMenuViewController rightMenuViewController:nil];
    
    [appDelegate.window setRootViewController:appDelegate.revealController];
    
    [appDelegate.window makeKeyAndVisible];
}

- (IBAction)btnKeepConnectingPressed:(id)sender
{
    [self performSegueWithIdentifier:@"ProfilePhotosToSelectGenderIdentifier" sender:nil];
    return;
    
     FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
     appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
   
     RearMenuViewController *rearMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
     appDelegate.revealController = [[ResideMenuViewController alloc] initWithContentViewController:appDelegate.frontNavigationController leftMenuViewController:rearMenuViewController rightMenuViewController:nil];
   
     [appDelegate.window setRootViewController:appDelegate.revealController];
   
     [appDelegate.window makeKeyAndVisible];
}
@end
