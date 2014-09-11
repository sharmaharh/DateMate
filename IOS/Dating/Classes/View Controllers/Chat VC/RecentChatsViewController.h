//
//  RecentChatsViewController.h
//  Dating
//
//  Created by Harsh Sharma on 8/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentChatsViewController : UIViewController

@property (assign, nonatomic) BOOL isFromPush;
- (IBAction)btnRevealPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRecentChats;

@end
