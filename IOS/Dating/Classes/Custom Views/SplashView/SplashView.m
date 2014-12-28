//
//  SplashView.m
//  Dating
//
//  Created by Harsh Sharma on 9/6/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "SplashView.h"

@implementation SplashView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = (SplashView *)[[NSBundle mainBundle] loadNibNamed:@"SplashView" owner:self options:nil][0];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 

*/




@end
