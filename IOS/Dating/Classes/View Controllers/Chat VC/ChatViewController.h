//
//  ChatViewController.h
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatAttachmentHelperClass.h"
#import "STBubbleTableViewCell.h"
#import "Message.h"

@interface ChatViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, STBubbleTableViewCellDataSource, STBubbleTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewChatWindow;
@property (weak, nonatomic) IBOutlet UITableView *tableViewChat;
@property (weak, nonatomic) IBOutlet UITextField *textFieldMessage;
@property (nonatomic, strong) NSMutableArray *messages;

+ (id)sharedChatInstance;

- (IBAction)btnRevealPressed:(id)sender;

- (IBAction)btnAttachmentPressed:(id)sender;
- (IBAction)btnSendMessagePressed:(id)sender;
- (void)recieveMessage:(NSString *)msg;

@end
