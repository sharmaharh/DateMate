//
//  HSProgressIndicator.h
//  Dating
//
//  Created by Harsh Sharma on 1/27/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSProgressIndicator : UIView

@property (strong, nonatomic) IBOutlet UIView *viewAnimation;

- (void)startLoading;
- (void)stopLoading;
- (void)customizeView;

@property (assign, nonatomic) BOOL isAnimating;

@end
