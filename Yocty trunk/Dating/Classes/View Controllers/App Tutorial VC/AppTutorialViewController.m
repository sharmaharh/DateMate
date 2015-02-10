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
    [self.pageControlTutorial setNumberOfPages:5];
    self.pageControlTutorial.currentPage = 0;
    
    for (int i = 0; i < 5; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(44, 5, self.view.frame.size.width, self.view.frame.size.height-64)];
        [imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"app_tutorial_%i",i]]];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        [self.scrollViewTutorial addSubview:imgView];
    }
    
    [self.scrollViewTutorial setContentSize:CGSizeMake(self.view.frame.size.width * 5, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSkipPressed:(id)sender
{
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
