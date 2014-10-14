//
//  FindMatchViewController.h
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindMatchViewController : UIViewController <UIScrollViewDelegate>

- (IBAction)passProfileButtonPressed:(id)sender;
- (IBAction)passEmotionsButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIButton *btnPassProfile;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImages;

- (IBAction)btnRevealPressed:(id)sender;

@end
