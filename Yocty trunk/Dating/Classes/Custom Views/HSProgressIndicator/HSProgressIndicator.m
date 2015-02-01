//
//  HSProgressIndicator.m
//  Dating
//
//  Created by Harsh Sharma on 1/27/15.
//  Copyright (c) 2015 IncredTechnologies. All rights reserved.
//

#import "HSProgressIndicator.h"

@implementation HSProgressIndicator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"HSProgressIndicator" owner:self options:nil] firstObject];
    self.frame = frame;
    return self;
}

-(void)customizeView
{
    for (int i = 1; i < 4; i++)
    {
        UIView *view = (UIView *)[self viewWithTag:i];
        [view.layer setCornerRadius:view.frame.size.width/2];
    }
    
    UIView *view = (UIView *)[self viewWithTag:10];
    [view.layer setCornerRadius:view.frame.size.width/2];
    
    UIView *view1 = (UIView *)[self viewWithTag:11];
    [view1.layer setCornerRadius:view1.frame.size.width/2];
    
    UIView *view2 = (UIView *)[self viewWithTag:4];
    [view2.layer setCornerRadius:view2.frame.size.width/3.5];
    
    [self bringSubviewToFront:[self viewWithTag:3]];
    [self sendSubviewToBack:[self viewWithTag:4]];
}

- (void)startLoading
{
    if (!self.isAnimating)
    {
        self.isAnimating = YES;
        [self startRotation];
        [self startAnimation];
    }
}

- (void)stopLoading
{
    self.isAnimating = NO;
}

- (void)startRotation
{
    if (self.isAnimating)
    {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.viewAnimation setTransform:CGAffineTransformRotate(self.viewAnimation.transform, M_PI-0.0001f)];
        }completion:^(BOOL finished){
            if (self.isAnimating)
            {
                [self startRotation];
            }
            
        }];
    }
}

- (void)startAnimation
{
    // Sequentially Scaling
    if (self.isAnimating)
    {
        [self.viewAnimation bringSubviewToFront:[self viewWithTag:10]];
        [self.viewAnimation sendSubviewToBack:[self viewWithTag:11]];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            
            [[self.viewAnimation viewWithTag:11] setTransform:CGAffineTransformMakeScale(0.001, 0.001)];
            
            [[self viewWithTag:10] setTransform:CGAffineTransformMakeScale(1,1)];
            
            
            
        } completion:^(BOOL finished) {
            if (self.isAnimating)
            {
                [self reverseAnimation1];
            }
            
        }];
    }
    
}

- (void)reverseAnimation1
{
    if (self.isAnimating)
    {
        [self.viewAnimation bringSubviewToFront:[self viewWithTag:11]];
        [self.viewAnimation sendSubviewToBack:[self viewWithTag:10]];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            [[self viewWithTag:11] setTransform:CGAffineTransformMakeScale(1,1)];
            [[self viewWithTag:10] setTransform:CGAffineTransformMakeScale(0.001,0.001)];
            
            
        } completion:^(BOOL finished) {
            if (self.isAnimating)
            {
                [self startAnimation];
            }
            
        }];
    }
    
}


@end
