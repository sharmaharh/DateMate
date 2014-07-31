//
//  ChatViewController.h
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatAttachmentHelperClass.h"

@interface ChatViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewChatWindow;
@property (weak, nonatomic) IBOutlet UITableView *tableViewChat;


- (IBAction)btnAttachmentPressed:(id)sender;
- (IBAction)btnSendMessagePressed:(id)sender;

@end
