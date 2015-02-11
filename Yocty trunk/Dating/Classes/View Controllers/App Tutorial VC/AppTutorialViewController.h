//
//  AppTutorialViewController.h
//  Dating
//
//  Created by Harsh Sharma on 10/02/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppTutorialViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewTutorial;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlTutorial;
@property (strong, nonatomic) IBOutlet UIView *viewPrototype;

- (IBAction)btnSkipPressed:(id)sender;

@end
