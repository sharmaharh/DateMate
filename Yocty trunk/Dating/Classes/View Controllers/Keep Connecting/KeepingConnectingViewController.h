//
//  KeepingConnectingViewController.h
//  Dating
//
//  Created by Harsh Sharma on 9/10/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFlabbyTableManager.h"
#import "BRFlabbyTableViewCell.h"

typedef enum : NSUInteger {
    kWink = 1,
    kStare,
    kWave,
    kSmile,
    kLikedByBoth,
    kDisliked,
    kBlocked,
    
} EMotionNotification;

@interface KeepingConnectingViewController : UIViewController <BRFlabbyTableManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewPendingEmotions;
@property (strong, nonatomic) BRFlabbyTableManager *flabbyTableManager;
@property (strong, nonatomic) IBOutlet UIView *viewRequestSent;
@property (strong, nonatomic) IBOutlet UILabel *lblRequestSent;

@end
