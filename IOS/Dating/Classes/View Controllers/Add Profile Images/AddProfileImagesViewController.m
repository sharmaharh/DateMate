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
    [self setProfileImagesOnButtons];
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

- (void)setImageWithButtonIndex:(NSInteger)btnIndex
{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.profileImagesArray[btnIndex-1]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:btnIndex+10];
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
                [self.profileImagesArray replaceObjectAtIndex:btnIndex-1 withObject:image];
                UIButton *btn = (UIButton *)[self.view viewWithTag:btnIndex];
                [btn setImage:image forState:UIControlStateNormal];
                [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
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

- (IBAction)btnEditPressed:(id)sender
{
    UserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    userProfileViewController.imagesArray = self.profileImagesArray;
    appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:userProfileViewController];
    
    RearMenuViewController *rearMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
    appDelegate.revealController = [[SWRevealViewController alloc] initWithRearViewController:rearMenuViewController frontViewController:appDelegate.frontNavigationController];
    
    [appDelegate.window setRootViewController:appDelegate.revealController];
    
    [appDelegate.window makeKeyAndVisible];
}

- (IBAction)btnKeepConnectingPressed:(id)sender
{
     FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
     appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
   
     RearMenuViewController *rearMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
     appDelegate.revealController = [[SWRevealViewController alloc] initWithRearViewController:rearMenuViewController frontViewController:appDelegate.frontNavigationController];
   
     [appDelegate.window setRootViewController:appDelegate.revealController];
   
     [appDelegate.window makeKeyAndVisible];
}
@end
