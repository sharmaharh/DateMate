//
//  AppTutorialViewController.m
//  Dating
//
//  Created by Harsh Sharma on 10/02/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import "AppTutorialViewController.h"

@interface AppTutorialViewController ()

@end

@implementation AppTutorialViewController

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
    
    [self setImagesOnScrollView];
}

- (void)setImagesOnScrollView
{
    [self.pageControlTutorial setNumberOfPages:4];
    self.pageControlTutorial.currentPage = 0;
    NSArray *textArray = @[@"Keep Connecting!\n Profiles will switch as the countdown ends and won't come back.",      @"Explore: Tap on the image to view full profile. Timer pauses when you enter detail view.",
                           @"Happy Going Famous: Feature on every Yocty users' splash screen as our algorithm chooses your profile for a day.",
                           @"Pending Requests: See who's waiting to date you in the Pending Emotion section"];
    
    for (int i = 0; i < 4; i++)
    {
        CGRect imgRect = [self.viewPrototype viewWithTag:10].frame;
        imgRect.origin.x = self.view.frame.size.width*i + imgRect.origin.x;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgRect];
        [imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"app_tutorial_%i",i+1]]];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        
        CGRect lblRect = [self.viewPrototype viewWithTag:11].frame;
        lblRect.origin.x = self.view.frame.size.width*i + imgRect.origin.x;
        
        UILabel *tutorialLabel = [[UILabel alloc] initWithFrame:lblRect];
        [tutorialLabel setNumberOfLines:0];
        tutorialLabel.font = ((UILabel *)[self.viewPrototype viewWithTag:11]).font;
        tutorialLabel.textColor = [UIColor whiteColor];
        [tutorialLabel setTextAlignment:NSTextAlignmentCenter];
        [tutorialLabel setText:textArray[i]];
        [tutorialLabel setAdjustsFontSizeToFitWidth:YES];
        
        [self.scrollViewTutorial addSubview:imgView];
        [self.scrollViewTutorial addSubview:tutorialLabel];
    }
    
    [self.scrollViewTutorial setContentSize:CGSizeMake(self.view.frame.size.width * 4, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSkipPressed:(id)sender
{
    for (UIView *view in self.scrollViewTutorial.subviews)
    {
        [view removeFromSuperview];
    }
    self.scrollViewTutorial = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger currentPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    self.pageControlTutorial.currentPage = currentPageIndex;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    self.pageControlTutorial.currentPage = currentPageIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger currentPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    self.pageControlTutorial.currentPage = currentPageIndex;
}

@end
