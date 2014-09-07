//
//  ChatViewController.m
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()
{
    NSString *headerTitle;
}

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
    [self getUserStatus];
    [self getChatHistory];
}

- (void)getUserStatus
{
    AFNHelper *afnHelper = [AFNHelper new];
    headerTitle = @"";
    [afnHelper getDataFromPath:@"getUserStatus" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_user_recever_fbid" : @"10203175848489479"} mutableCopy] withBlock:^(id response, NSError *error) {
        
        headerTitle = response[@"Status"][0][@"lastActiveDateTZ"];
        
        if (!headerTitle.length)
        {
            headerTitle = @"";
        }
        
        [self.tableViewChat reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//        NSDateFormatter *dateFormatter = [NSDateFormatter new];
//        dateFormatter.dateFormat = @"YYYY-MM-d h:m:s";
//        NSDate * lastSeenDate = [dateFormatter dateFromString:lastSeenDateString];
//        [NSDate timeIntervalSinceReferenceDate]
        
    }];
}


- (void)getChatHistory
{
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"getChatHistory" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_user_recever_fbid" : @"10203175848489479", @"ent_chat_page" : @"1"} mutableCopy] withBlock:^(id response, NSError *error) {
        
        if ([response[@"chat"] count])
        {
            [self filterChatHistoryList:response[@"chat"]];
        }
    }];
}


- (void)filterChatHistoryList:(NSArray *)chatHistory
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-d h:m:s"];
    
    NSComparator myDateComparator = ^NSComparisonResult(NSDictionary *obj1,
                                                        NSDictionary *obj2) {
        NSDate *date1 = [formatter dateFromString:obj1[@"dt"]];
        NSDate *date2 = [formatter dateFromString:obj2[@"dt"]];
        
        return [date2 compare:date1]; // sort in descending order
    };
//    then simply sort the array by doing:
    
    NSArray *sortedArray = [chatHistory sortedArrayUsingComparator:myDateComparator];
    
    for (int i = 0; i < sortedArray.count; i++)
    {
        Message *msg = [Message messageWithDictionary:sortedArray[i]];
        [self.messages insertObject:msg atIndex:i];
    }
    
    [self.tableViewChat reloadData];
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
        [self.tableViewChat setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44)];
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
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYY-MM-d h:m:s"];
        
        NSDictionary *msgDict = @{msg_ID: @"", msg_Sender_ID : [FacebookUtility sharedObject].fbID, msg_Reciver_ID : @"10203175848489479", msg_Sender_Name : [FacebookUtility sharedObject].fbFullName, msg_text : self.textFieldMessage.text, msg_Date : [dateFormatter stringFromDate:[NSDate date]]};
        
        [self.messages addObject:[Message messageWithDictionary:msgDict]];
//        [self.messages addObject:[Message messageWithString:self.textFieldMessage.text isMySentMessage:YES]];
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
    if (self.tableViewChat.frame.size.height < self.tableViewChat.contentSize.height)
    {
        [self.tableViewChat setContentOffset:CGPointMake(0, self.tableViewChat.contentSize.height-self.tableViewChat.frame.size.height) animated:YES];
        
    }
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"sendMessage" withParamData:[NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,@"10203175848489479",self.textFieldMessage.text] forKeys:@[@"ent_user_fbid",@"ent_user_recever_fbid",@"ent_message"]] withBlock:^(id response, NSError *error) {
        
        NSLog(@"Message Sent Response = %@",response);
    }];
}

- (void)recieveMessage:(NSDictionary *)messageDict
{
    [self.messages addObject:[Message messageWithDictionary:messageDict]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return headerTitle.length?[@"last seen at " stringByAppendingString:headerTitle]:@"";
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
        cell = [[STBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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
    cell.detailTextLabel.text = @"Today";
    cell.bubbleColor = STBubbleTableViewCellBubbleColorGreen;
    
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
        [self.tableViewChat setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-self.viewChatWindow.frame.size.height-216)];
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
        [self.tableViewChat setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44)];
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.16 animations:^{
        [self.tableViewChat setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44)];
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, 0)];
        
    }];
    [textField resignFirstResponder];
    return YES;
}

@end
