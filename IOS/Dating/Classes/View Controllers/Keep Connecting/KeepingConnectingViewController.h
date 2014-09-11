//
//  KeepingConnectingViewController.h
//  Dating
//
//  Created by Harsh Sharma on 9/10/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kWink = 1,
    kStare,
    kWave,
    kSmile,
    kLikedByBoth,
    kDisliked,
    kBlocked,
    
} EMotionNotification;

@interface KeepingConnectingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableViewPendingEmotions;

- (IBAction)btnRevealPressed:(id)sender;

@end
