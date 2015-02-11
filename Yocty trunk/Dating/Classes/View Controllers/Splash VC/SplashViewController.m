//
//  SplashViewController.m
//  Dating
//
//  Created by Harsh Sharma on 1/26/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import "SplashViewController.h"
#import "FindMatchViewController.h"
#import "LogInViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self showExistingSplashImage];
    
    [self moveToAppFlow];
    
    [self downloadLatestSplashImage];
}

- (void)showExistingSplashImage
{
    NSString *filePath = [FileManager SplashImageFolderPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self.viewProfileOfDay setHidden:YES];
    NSArray *imagesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
    if([imagesArray count])
    {
        UIImage *splashImage = [UIImage imageWithContentsOfFile:[filePath stringByAppendingPathComponent:[imagesArray firstObject]]];
        if (splashImage)
        {
            [self.viewProfileOfDay setHidden:NO];
            [self.imageViewSplash.layer setCornerRadius:self.imageViewSplash.frame.size.height/2.0];
            [self.imageViewSplash.layer setBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor];
            [self.imageViewSplash.layer setBorderWidth:5.0];
            [self.imageViewSplash setClipsToBounds:YES];
            [self.imageViewSplash setContentMode:UIViewContentModeScaleToFill];
            [self.imageViewSplash setImage:[Utils scaleImage:splashImage WithRespectToFrame:self.imageViewSplash.frame]];
            self.labelUsername.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"FamousUserName"];
            self.labelUserLocation.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"FamousUserLocation"];
        }
        else
        {
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
    }
}

- (void)moveToAppFlow
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LoginPersistingClass"] length])
        {
            appDelegate.frontNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FirstNavigationController"];
            [appDelegate.frontNavigationController setNavigationBarHidden:YES];
            [appDelegate.frontNavigationController pushViewController:[mainStoryBoard instantiateViewControllerWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"LoginPersistingClass"]] animated:NO];
            [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
            [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
            appDelegate.window.rootViewController = appDelegate.frontNavigationController;
        }
        else
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"] length])
            {
                // Find Match
                
                FindMatchViewController *findMatchViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
                appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
                [appDelegate.frontNavigationController setNavigationBarHidden:YES];
                [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
                [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
                
                appDelegate.revealController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ResideMenuViewController"];
                appDelegate.revealController.contentViewController = appDelegate.frontNavigationController;
                [appDelegate.window setRootViewController:appDelegate.revealController];
                
            }
            else
            {
                // Login
                LogInViewController *logInViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"LogInViewController"];
                appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:logInViewController];
                [appDelegate.frontNavigationController setNavigationBarHidden:YES];
                appDelegate.window.rootViewController = appDelegate.frontNavigationController;
            }
        }
        
    });
}

- (void)downloadLatestSplashImage
{
    // Download Image
    if ([Utils isInternetAvailable])
    {
        AFNHelper *afnHelper = [[AFNHelper alloc] init];
        [afnHelper getDataFromPath:@"splashImages" withParamData:nil withBlock:^(id response, NSError *error) {
            if (!error && response)
            {
                if ([response isKindOfClass:[NSDictionary class]])
                {
                    
                    if ([response[@"Userphotos"] isKindOfClass:[NSArray class]])
                    {
                        NSArray *splashImagesArray = response[@"Userphotos"];
                        if([response[@"Name"] length])
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:response[@"Name"] forKey:@"FamousUserName"];
                        }
                        if([response[@"Country"] length])
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:response[@"Country"] forKey:@"FamousUserLocation"];
                        }
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    
                        if ([splashImagesArray count])
                        {
                            
                            
                            [[HSImageDownloader sharedInstance] imageWithImageURL:[splashImagesArray firstObject][@"image_url"] withFBID:nil withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
                                
                                NSLog(@"Splash Downloaded");
                            }];
                            
                            
                        }
                    }
                    
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
