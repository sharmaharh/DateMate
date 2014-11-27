//
//  ResideMenuViewController.m
//  Dating
//
//  Created by Harsh Sharma on 27/11/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "ResideMenuViewController.h"

@interface ResideMenuViewController ()

@end

@implementation ResideMenuViewController

- (void)awakeFromNib
{
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.contentViewShadowColor = [UIColor blackColor];
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    
    [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
    [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
    
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
    self.delegate = self;
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end

