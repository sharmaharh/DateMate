//
//  ChatViewController.m
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()


@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (id)sharedChatInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        sharedInstance = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    });
    return sharedInstance;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messages = [NSMutableArray array];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -----
#pragma mark IBActions

- (IBAction)btnAttachmentPressed:(id)sender
{
    [UIView animateWithDuration:0.16 animations:^{
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }];
    [self.textFieldMessage resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Attachment" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Image",@"Video",@"Audio", nil];
    actionSheet.tag = 1;
    [actionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
}

- (IBAction)btnSendMessagePressed:(id)sender
{
    if (self.textFieldMessage.text.length)
    {
        [self.messages addObject:[Message messageWithString:self.textFieldMessage.text isMySentMessage:YES]];
        [self.tableViewChat reloadData];
        [self sendMessage];
    }
    else
    {
        [Utils showOKAlertWithTitle:@"Message" message:@"Please Enter Message"];
    }
    
}

- (void)sendMessage
{
    
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"sendMessage" withParamData:[NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,@"10203175848489479",self.textFieldMessage.text] forKeys:@[@"ent_user_fbid",@"ent_user_recever_fbid",@"ent_message"]] withBlock:^(id response, NSError *error) {
        NSLog(@"Message Sent Response = %@",response);
    }];
}

- (void)recieveMessage:(NSString *)msg
{
    [self.messages addObject:[Message messageWithString:msg isMySentMessage:NO]];
    [self.tableViewChat reloadData];
}

#pragma mark -----
#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    switch (actionSheet.tag)
    {
            
        case 1:
        {
            
            // Attachment List Action Sheet
            
            switch (buttonIndex)
            {
                    
                case 0:
                    // Image
                    [[ChatAttachmentHelperClass sharedInstance] openImagePickerControllerForImageForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                    break;
                    
                case 1:
                    // Video
                    
                    break;
                    
                case 2:
                    // Audio
                    [[ChatAttachmentHelperClass sharedInstance] startAudioRecording];
                    break;
                    
                default:
                    break;
                    
            }
            
        }
            break;
            
            
        case 2: case 3:
        {
            
            // Image and Video picker
            [[ChatAttachmentHelperClass sharedInstance] openImagePickerControllerForImageForSourceType:buttonIndex];
            
        }
            break;
            
            
        default:
            break;
    }
}

#pragma mark -----
#pragma mark UITableViewDelegate & DataSource

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Bubble Cell";
    
    STBubbleTableViewCell *cell = (STBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[STBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = tableView.backgroundColor;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
		cell.dataSource = self;
		cell.delegate = self;
	}
	
	Message *message = [self.messages objectAtIndex:indexPath.row];
	
	cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
	cell.textLabel.text = message.message;
	cell.imageView.image = message.avatar;
	
    // Put your own logic here to determine the author
    
    cell.authorType = !message.isMySentMessage;
    cell.bubbleColor = STBubbleTableViewCellBubbleColorGreen;
    
//	if(indexPath.row % 2 != 0 || indexPath.row == 4)
//	{
//		cell.authorType = STBubbleTableViewCellAuthorTypeSelf;
//		cell.bubbleColor = STBubbleTableViewCellBubbleColorGreen;
//	}
//	else
//	{
//		cell.authorType = STBubbleTableViewCellAuthorTypeOther;
//		cell.bubbleColor = STBubbleTableViewCellBubbleColorGray;
//	}
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Message *message = [self.messages objectAtIndex:indexPath.row];
	
	CGSize size;
	
	if(message.avatar)
    {
		size = [message.message sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - STBubbleImageSize - 8.0f - STBubbleWidthOffset, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
	else
    {
		size = [message.message sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(tableView.frame.size.width - [self minInsetForCell:nil atIndexPath:indexPath] - STBubbleWidthOffset, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
	
	// This makes sure the cell is big enough to hold the avatar
	if(size.height + 15.0f < STBubbleImageSize + 4.0f && message.avatar)
    {
		return STBubbleImageSize + 4.0f;
    }
	
	return size.height + 15.0f;
}

#pragma mark - STBubbleTableViewCellDataSource methods

- (CGFloat)minInsetForCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
		return 100.0f;
    }
    
	return 50.0f;
}

#pragma mark - STBubbleTableViewCellDelegate methods

- (void)tappedImageOfCell:(STBubbleTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Message *message = [self.messages objectAtIndex:indexPath.row];
	NSLog(@"%@", message.message);
}

#pragma mark ----
#pragma mark UITextfield Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, -216)];
        
    }];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.16 animations:^{
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.16 animations:^{
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }];
    [textField resignFirstResponder];
    return YES;
}

@end
