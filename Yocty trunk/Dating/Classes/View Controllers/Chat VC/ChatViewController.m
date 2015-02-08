//
//  ChatViewController.m
//  Dating
//
//  Created by Harsh Sharma on 7/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatHistory.h"
#import "ChatPartners.h"
#import "AudioRecordingView.h"
#import "FullImageViewController.h"


@interface ChatViewController ()
{
    NSString *headerTitle;
    NSInteger totalChatCount;
    BOOL isFirstTime;
    MPMoviePlayerViewController *moviePlayer;
    
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
    isFirstTime = YES;
    self.tableViewChat.sectionFooterHeight = 0;
    totalChatCount = 0;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isFirstTime)
    {
        isFirstTime = NO;
        self.messages = [NSMutableArray array];
        [self.tableViewChat reloadData];
        if (![self.recieveFBID length])
        {
            self.recieveFBID = @"";
        }
        
//        [self getUserStatus];
        
//        [self getChatHistory];
    }
    [self connectToSocket];
}

- (void)connectToSocket
{
    [[MyWebSocket sharedInstance] connectSocketWithBlock:^(BOOL connected, NSError *error) {
        
        if (connected)
        {
            [[MyWebSocket sharedInstance] sendText:@{@"type" : @"participate", @"userId" : [FacebookUtility sharedObject].fbID, @"roomId" : self.recieveFBID} acknowledge:^(NSDictionary *messageDict, NSError *error) {
                if (!error)
                {
                    if ([[messageDict allKeys] containsObject:@"type"] && [messageDict objectForKey:@"type"])
                    {
                        if ([[messageDict objectForKey:@"type"] isEqualToString:@"message"])
                        {
                            NSLog(@" Participate Message Recieved = %@",messageDict);
                            
                            if (!self.messages)
                            {
                                self.messages = [NSMutableArray array];
                            }
                            
                            if ([messageDict[@"body"][@"chat"] count])
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if ([messageDict[@"body"][@"chat"] isKindOfClass:[NSArray class]])
                                    {
                                        [self recieveMessages:messageDict[@"body"][@"chat"]];
                                    }
                                    else
                                    {
                                        [self recieveMessage:messageDict[@"body"][@"chat"]];
                                    }
                                    
                                    
                                });
                                
                                
                            }
                            
                        }
                        else if ([[messageDict objectForKey:@"type"] isEqualToString:@"mediaUpload"])
                        {
                            //                        [self.tableViewChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                            
                            //                    if ([messageDict[@"body"][@"isUpload"] boolValue])
                            //                    {
                            //
                            //                        [self.tableViewChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                            //
                            ////                        Message *msgToWatch = [[self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                            ////                            Message *msgObject=(Message *) evaluatedObject;
                            ////                            return ([msgObject.messageID hasPrefix:messageDict[@"body"][msg_ID]]);
                            ////                        }]] firstObject];
                            ////
                            ////                        if (msgToWatch)
                            ////                        {
                            ////                            NSInteger index = [self.messages indexOfObject:msgToWatch];
                            ////                            if ([self.messages count] > index)
                            ////                            {
                            ////                                [self.tableViewChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                            ////                            }
                            ////
                            ////                        }
                            //                    }
                        }
                    }
                }
                
            }];
        }
        
    }];
}

- (void)getUserStatus
{
    if ([Utils isInternetAvailable])
    {
        AFNHelper *afnHelper = [AFNHelper new];
        headerTitle = @"";
        [afnHelper getDataFromPath:@"getUserStatus" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_user_recever_fbid" : self.recieveFBID} mutableCopy] withBlock:^(id response, NSError *error) {
            
            if ([response[@"Status"] count])
            {
                headerTitle = response[@"Status"][0][@"lastActiveDateTZ"];
                
                if (!headerTitle.length)
                {
                    headerTitle = @"";
                }
                
                [self.tableViewChat reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            //        NSDateFormatter *dateFormatter = [NSDateFormatter new];
            //        dateFormatter.dateFormat = @"YYYY-MM-d h:m:s";
            //        NSDate * lastSeenDate = [dateFormatter dateFromString:lastSeenDateString];
            //        [NSDate timeIntervalSinceReferenceDate]
            
        }];
    }
    
}

- (void)saveTotalCountofMessages
{
//    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ChatPartners"];
//    NSPredicate *chatPredicate  = [NSPredicate predicateWithFormat:@"%K = %@",msg_Reciver_ID,self.recieveFBID];
//    
//    [request setPredicate:chatPredicate];
//    NSError *error = nil;
//    
//    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
//    
//    ChatPartners *chatPartner = (ChatPartners *)[results firstObject];
//    chatPartner.totalChatCount = [NSNumber numberWithInt:totalChatCount];
//    [appDelegate.managedObjectContext save:nil];
}

- (void)getChatHistory
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ChatHistory"];
    NSPredicate *chatPredicate  = [NSPredicate predicateWithFormat:@"(%K = %@ AND %K = %@) OR (%K = %@ AND %K = %@)",msg_Sender_ID,[FacebookUtility sharedObject].fbID,msg_Reciver_ID,self.recieveFBID,      msg_Sender_ID,self.recieveFBID,msg_Reciver_ID,[FacebookUtility sharedObject].fbID];
    
    [request setPredicate:chatPredicate];
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
//    if ([results count] || ![Utils isInternetAvailable])
    if(0)
    {
        //Deal with Database
        NSMutableArray *tempArray = [NSMutableArray array];
        for (ChatHistory *chat in results)
        {
            NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
            msgDict[msg_ID]          = chat.mid;
            msgDict[msg_Date]        = chat.dt;
            msgDict[msg_text]        = chat.msg;
            msgDict[msg_Sender_ID]   = chat.sfid;
            msgDict[msg_Reciver_ID]  = chat.rfid;
            msgDict[msg_Sender_Name] = chat.sname;
            [tempArray addObject:msgDict];
            
        }
        
        NSArray *sortedArray = [self filterArrayInChronologicalDescendingOrderFromArray:tempArray];
        
        for (int i = 0; i < sortedArray.count; i++)
        {
            Message *msg = [Message messageWithDictionary:sortedArray[i]];
            [self.messages addObject:msg];
        }
        
        [self.tableViewChat reloadData];
        
        if (self.tableViewChat.contentSize.height > self.tableViewChat.frame.size.height)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableViewChat setContentOffset:CGPointMake(0, self.tableViewChat.contentSize.height-self.tableViewChat.frame.size.height) animated:YES];
            });
            
        }
        [self disableChatAccordingToStatus];
    }
    
    else
    {
        //Deal with Service
        if ([Utils isInternetAvailable])
        {
            AFNHelper *afnHelper = [AFNHelper new];
            [afnHelper getDataFromPath:@"getChatHistory" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_user_recever_fbid" : self.recieveFBID, @"ent_chat_page" : @"1"} mutableCopy] withBlock:^(id response, NSError *error) {
                
                if ([response[@"chat"] count])
                {
                    totalChatCount = [response[@"chatTotalCount"] integerValue];
                    [self saveTotalCountofMessages];
                    [self filterChatHistoryList:response[@"chat"]];
                }
                [self disableChatAccordingToStatus];
            }];
        }
        
    }
}


- (void)filterChatHistoryList:(NSArray *)chatHistory
{
    NSArray *sortedArray = [self filterArrayInChronologicalDescendingOrderFromArray:chatHistory];
    
    for (int i = 0; i < sortedArray.count; i++)
    {
        Message *msg = [Message messageWithDictionary:sortedArray[i]];
        [self.messages addObject:msg];
        [self addMessageToDatabase:msg];
    }
    
    [self.tableViewChat reloadData];
    
    if (self.tableViewChat.contentSize.height > self.tableViewChat.frame.size.height)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableViewChat setContentOffset:CGPointMake(0, self.tableViewChat.contentSize.height-self.tableViewChat.frame.size.height) animated:YES];
        });
    }
    
}

- (NSArray *)filterArrayInChronologicalDescendingOrderFromArray:(NSArray *)chatArray
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
    return [chatArray sortedArrayUsingComparator:myDateComparator];
    
}

- (void)addMessageToDatabase:(Message *)msg
{
    [self disableChatAccordingToStatus];
    ChatHistory *chat = [NSEntityDescription insertNewObjectForEntityForName:@"ChatHistory" inManagedObjectContext:appDelegate.managedObjectContext];
    
    chat.dt    = msg.messageDate;
    chat.mid   = [NSString stringWithFormat:@"%@",msg.messageID];
    chat.msg   = msg.message;
    chat.rfid  = msg.messageReciverID;
    chat.sfid  = msg.messageSenderID;
    chat.sname = msg.messageSenderName;
    
    [appDelegate.managedObjectContext save:nil];
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
    [actionSheet showInView:self.view];
}

- (IBAction)btnSendMessagePressed:(id)sender
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"YYYY-MM-d h:m:s"];
    
    NSDictionary *msgDict = [NSDictionary dictionary];
    
    switch (self.attachmentType)
    {
        case kText:
        {
            if (self.textFieldMessage.text.length)
            {
                msgDict = @{msg_ID: @"", msg_Sender_ID : [FacebookUtility sharedObject].fbID, msg_Reciver_ID : self.recieveFBID, msg_Sender_Name : [FacebookUtility sharedObject].fbFullName, msg_text : self.textFieldMessage.text, msg_Date : [dateFormatter stringFromDate:[NSDate date]],msg_Media_Section : [NSString stringWithFormat:@"%i",self.attachmentType]};
                
            }
            else
            {
                [Utils showOKAlertWithTitle:@"Message" message:@"Please Enter Message"];
            }
        }
            break;
            
        case kImage: case KVideo: case kAudio:
        {
            if ([ChatAttachmentHelperClass sharedInstance].attachmentData)
            {
                msgDict = @{msg_ID: @"", msg_Sender_ID : [FacebookUtility sharedObject].fbID, msg_Reciver_ID : self.recieveFBID, msg_Sender_Name : [FacebookUtility sharedObject].fbFullName, msg_text : @"", msg_Date : [dateFormatter stringFromDate:[NSDate date]],msg_Media:[ChatAttachmentHelperClass sharedInstance].attachmentData,msg_Media_Section : [NSString stringWithFormat:@"%i",self.attachmentType],msg_Media_URL:[ChatAttachmentHelperClass sharedInstance].attachmentURL};
                
            }
            else
            {
                [Utils showOKAlertWithTitle:@"Message" message:@"Please Enter Message"];
            }
        }
            break;
            
            
        default:
            break;
    }
    
    
    [self.messages addObject:[Message messageWithDictionary:msgDict]];
    totalChatCount ++;
    [self addMessageToDatabase:[self.messages lastObject]];
    //        [self.messages addObject:[Message messageWithString:self.textFieldMessage.text isMySentMessage:YES]];
    [self.tableViewChat reloadData];
    [self sendMessage];
    
}

- (void)disableChatAccordingToStatus
{
    /*
     (
     {
     fName = Harsh;
     fbId = 661762160568643;
     flag = 5;
     "flag_initiate" = 1;
     "flag_mine" = 5;
     "flag_mine_state" = 2;
     "flag_state" = 2;
     ladt = "2014-10-19 01:44:10";
     pPic = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/p200x200/6417_608575192554007_3093356137364336146_n.jpg?oh=7045032972f327d13d3a49e4ab1fde90&oe=54F06B41&__gda__=1421115652_843d8854c4078520639b5bb65a79b95f";
     }
     );
     */
    
    int minNum = MIN([self.chatFlag_State intValue], [self.chatFlag_Mine_State intValue]);
    
    if (minNum == 1 && totalChatCount >= 10)
    {
        // Stare Emotion
        [self.viewChatWindow setUserInteractionEnabled:NO];
        [self.viewChatWindow setAlpha:0.5];
        self.tableViewChat.sectionFooterHeight = 60;
        [self.tableViewChat reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (minNum == 2 && totalChatCount >= 20)
    {
        // Wave Emotion
        [self.viewChatWindow setUserInteractionEnabled:NO];
        [self.viewChatWindow setAlpha:0.5];
        self.tableViewChat.sectionFooterHeight = 60;
        [self.tableViewChat reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (minNum == 3 && totalChatCount >= 30)
    {
        // Smile Emotion
        [self.viewChatWindow setUserInteractionEnabled:NO];
        [self.viewChatWindow setAlpha:0.5];
        self.tableViewChat.sectionFooterHeight = 60;
        [self.tableViewChat reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        [self.viewChatWindow setUserInteractionEnabled:YES];
        [self.viewChatWindow setAlpha:1.0];
        self.tableViewChat.sectionFooterHeight = 0;
        [self.tableViewChat reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)sendMessage
{
    if (self.tableViewChat.frame.size.height < self.tableViewChat.contentSize.height)
    {
        [self.tableViewChat setContentOffset:CGPointMake(0, self.tableViewChat.contentSize.height-self.tableViewChat.frame.size.height) animated:YES];
        
    }
    
    NSMutableDictionary *reqDict = [NSMutableDictionary dictionary];
    
    AFNHelper *afnHelper = [AFNHelper new];
    
    if (self.attachmentType == kText)
    {
        reqDict = [NSMutableDictionary dictionaryWithObjects:@[@"message",[FacebookUtility sharedObject].fbID,self.recieveFBID,[NSString stringWithFormat:@"%i",self.attachmentType],self.textFieldMessage.text] forKeys:@[@"type",@"ent_user_fbid",@"ent_user_recever_fbid",@"ent_media_action",@"ent_message"]];
        
        [[MyWebSocket sharedInstance] sendText:reqDict acknowledge:^(NSDictionary *messageDict, NSError *error) {
            if (!error)
            {
                 NSLog(@"Message Recieved = %@",messageDict);
            }
            
        }];
        
//        [afnHelper getDataFromPath:@"sendMessage" withParamData:reqDict withBlock:^(id response, NSError *error) {
//            
//            NSLog(@"Message Sent Response = %@",response);
//        }];
    }
    else
    {
        reqDict = [NSMutableDictionary dictionaryWithObjects:@[@"message",[FacebookUtility sharedObject].fbID,self.recieveFBID,[NSString stringWithFormat:@"%i",self.attachmentType],@""] forKeys:@[@"type",@"ent_user_fbid",@"ent_user_recever_fbid",@"ent_media_action",@"ent_message"]];
        
        NSString *typeString = [NSString stringWithFormat:@"setFilename__1001__%@__%@__%i",[FacebookUtility sharedObject].fbID,self.recieveFBID,self.attachmentType];
        
        reqDict = [NSMutableDictionary dictionaryWithObjects:@[typeString,[ChatAttachmentHelperClass sharedInstance].attachmentData] forKeys:@[@"type",@"data"]];
        
        if (self.attachmentType == kImage)
        {
//            [[MyWebSocket sharedInstance] sendData:reqDict acknowledge:^(NSDictionary *messageDict, NSError *error) {
//                if (!error)
//                {
//                    NSLog(@"Message Recieved = %@",messageDict);
//                }
//                
//            }];
            
            [afnHelper getDataFromPath:@"sendMessage" withParamDataImage:reqDict andImage:[UIImage imageWithData:[ChatAttachmentHelperClass sharedInstance].attachmentData] withBlock:^(id response, NSError *error) {
                NSLog(@"Message Sent Response = %@",response);
            }];
        }
        else
        {
            [afnHelper getDataFromPath:@"sendMessage" withMultipartParamDataImage:reqDict withMimeType:[NSString stringWithFormat:@"%@/%@",((self.attachmentType == kAudio)?@"audio":@"video"),[[ChatAttachmentHelperClass sharedInstance].attachmentURL pathExtension]] andData:[ChatAttachmentHelperClass sharedInstance].attachmentData withBlock:^(id response, NSError *error) {
                NSLog(@"Message Sent Response = %@",response);
                ((Message *)[self.messages lastObject]).attachmentURL = response[@"chat"][msg_Media_URL];
            }];
            
        }
        
    }
    
    self.attachmentType = kText;
}

- (void)recieveMessage:(NSDictionary *)messageDict
{
    [self makeMessageModel:messageDict];
    
    [self.tableViewChat insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableViewChat scrollRectToVisible:self.tableViewChat.tableFooterView.frame animated:YES];
    
    totalChatCount ++;
}

- (void)recieveMessages:(NSArray *)messages
{
    for (NSDictionary *messageDict in messages)
    {
        [self makeMessageModel:messageDict];
        
    }
    [self.tableViewChat reloadData];
    [self.tableViewChat scrollRectToVisible:self.tableViewChat.tableFooterView.frame animated:YES];
    
    totalChatCount = totalChatCount + [messages count];
}

- (void)makeMessageModel:(NSDictionary *)msgDict
{
    Message *message = [Message messageWithDictionary:msgDict];
    
    if (message.attachmentType == 2 || message.attachmentType == 3 || message.attachmentType == 5)
    {
        message.attachmentURL = message.message;
    }
    
    if ([[msgDict allKeys] containsObject:@"alert"])
    {
        [self.messages addObject:message];
    }
    else
    {
        [self.messages addObject:message];
        
    }
}

#pragma mark -----
#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [ChatAttachmentHelperClass sharedInstance].attchmentDelegate = self;
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
                    [[ChatAttachmentHelperClass sharedInstance] openImagePickerControllerForVideo];
                    break;
                    
                case 2:
                    // Audio
                {
                    AudioRecordingView *audioRecordingView = [[AudioRecordingView alloc] initWithFrame:self.view.frame];
                    [self.view addSubview:audioRecordingView];
                }
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

- (void)openAudioRecordingView
{
    UIView *audioRecordingView = [[UIView alloc] initWithFrame:self.view.frame];
    [audioRecordingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    
    UIView *audioRecorderframe = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 280, 100)];
    [audioRecordingView setBackgroundColor:[UIColor whiteColor]];
    [audioRecordingView addSubview:audioRecorderframe];
    
    UIButton *playStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playStopButton setFrame:CGRectMake(0, 30, 40, 40)];
    [playStopButton setTitle:@"Play" forState:UIControlStateNormal];
    [playStopButton setTitle:@"Stop" forState:UIControlStateSelected];
    [playStopButton addTarget:self action:@selector(playStopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [playStopButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [audioRecorderframe addSubview:playStopButton];
    
    
    UIProgressView *recordingProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [recordingProgressView setFrame:CGRectMake(40, 40, 180, 20)];
    [recordingProgressView setProgress:0];
    
    UISlider *playerSlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 40, 180, 20)];
    [playerSlider setMaximumValue:100];
    [playerSlider setMinimumValue:0];
    [playerSlider addTarget:self action:@selector(playerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)playerSliderValueChanged: (UISlider *)slider
{
    
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
    return headerTitle.length?22:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    CGSize size;
    
    if (message.attachmentType == kText)
    {
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
    }
    else if(message.attachmentType == kAudio)
    {
        size = CGSizeMake(200, 40);
    }
    else
    {
        size = CGSizeMake(200, 160);
    }
    
    
    return size.height + 40.0f;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return headerTitle.length?[@"last seen at " stringByAppendingString:headerTitle]:@"";
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ([self.chatFlag intValue]!=5)?60:0)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 250, 50)];
    [statusLabel setNumberOfLines:3];
    [statusLabel setText:@"Messages Limit is completed for current Emotion, Move to next emotion for more Messages."];
    [statusLabel setFont:[UIFont systemFontOfSize:13]];
    UIButton *emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emotionButton setFrame:CGRectMake(260, 15, 55, 30)];
    [emotionButton addTarget:self action:@selector(passEmotionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [emotionButton setBackgroundColor:[UIColor redColor]];
    [emotionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self titleForPassEmotionButton:emotionButton];
    [emotionButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [footerView addSubview:statusLabel];
    [footerView addSubview:emotionButton];
    return footerView;
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
    cell.authorType = !message.isMySentMessage;
    [[cell viewWithTag:1] removeFromSuperview];
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
    
    if (message.attachmentType == kText)
    {
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.textLabel.text = message.message;
        cell.textLabel.textAlignment = cell.authorType?NSTextAlignmentLeft:NSTextAlignmentRight;
        cell.imageView.image = message.avatar;
        
        // Put your own logic here to determine the author
        cell.detailTextLabel.text = message.messageDate;
        cell.detailTextLabel.textAlignment = cell.authorType?NSTextAlignmentLeft:NSTextAlignmentRight;
        cell.bubbleColor = STBubbleTableViewCellBubbleColorBlue;
    }
    else if(message.attachmentType == kImage)
    {
        
        UIButton *cellImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cellImageButton.backgroundColor = [UIColor yellowColor];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        cellImageButton.tag = 1;
        [cellImageButton setContentMode:UIViewContentModeCenter];
        cellImageButton.accessibilityIdentifier = [NSString stringWithFormat:@"%li",(long)indexPath.row];
        [cellImageButton addTarget:self action:@selector(previewImageInFullScreenMode:) forControlEvents:UIControlEventTouchUpInside];
        
        if (cell.authorType)
        {
            // Other Person
            cellImageButton.frame = CGRectMake(10, 10, 180, 180);
            activityIndicator.frame = CGRectMake(80, 80, 40, 40);
            [self setImageOnButton:cellImageButton WithURL:message.attachmentURL WithProgressIndicator:activityIndicator];
        }
        else
        {
            cellImageButton.frame = CGRectMake(cell.frame.size.width-190, 10, 180, 180);
            activityIndicator.frame = CGRectMake(cell.frame.size.width-120, 80, 40, 40);
            if ([message.attachmentData length])
            {
                [cellImageButton setImage:[UIImage imageWithData:message.attachmentData] forState:UIControlStateNormal];
            }
            else
            {
                [self setImageOnButton:cellImageButton WithURL:message.attachmentURL WithProgressIndicator:activityIndicator];
            }
            
        }
        [cell addSubview:cellImageButton];
        [cell addSubview:activityIndicator];
        cell.bubbleColor = -326;
    }
    else if(message.attachmentType == KVideo)
    {
        UIButton *cellImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cellImageButton setContentMode:UIViewContentModeCenter];
        [cellImageButton setBackgroundColor:[UIColor redColor]];
        [cellImageButton setTitle:@"Video" forState:UIControlStateNormal];
        cellImageButton.tag = 1;
        
        BOOL isFileURL = ([message.attachmentURL rangeOfString:[self AttachmentsFolderPath]].location != NSNotFound);
        
        if (cell.authorType)
        {
            // Other Person
            cellImageButton.frame = CGRectMake(10, 10, 180, 180);
//            activityIndicator.frame = CGRectMake(80, 80, 40, 40);
            

        }
        else
        {
            cellImageButton.frame = CGRectMake(cell.frame.size.width-190, 10, 180, 180);
            
//            [cellImageButton setImage:[UIImage imageWithData:[ChatAttachmentHelperClass sharedInstance].attachmentData] forState:UIControlStateNormal];
        }
        
        if (!isFileURL)
        {
            NSString *imagePath = [[self AttachmentsFolderPath] stringByAppendingPathComponent:[[[message.attachmentURL lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
            {
                [cellImageButton setImage:[UIImage imageWithContentsOfFile:imagePath] forState:UIControlStateNormal];
            }
        }
        else
        {
            
        }
        
        [cellImageButton addTarget:self action:@selector(previewVideo:) forControlEvents:UIControlEventTouchUpInside];
        cellImageButton.accessibilityIdentifier = [NSString stringWithFormat:@"%li",(long)indexPath.row];
        
        [cell addSubview:cellImageButton];
        cell.bubbleColor = -326;
    }
    else
    {
        UIButton *cellImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cellImageButton setContentMode:UIViewContentModeCenter];
        [cellImageButton setBackgroundColor:[UIColor purpleColor]];
        [cellImageButton setTitle:@"Audio" forState:UIControlStateNormal];
        cellImageButton.tag = 1;
        if (cell.authorType)
        {
            // Other Person
            cellImageButton.frame = CGRectMake(10, 10, 180, 80);
            //            activityIndicator.frame = CGRectMake(80, 80, 40, 40);
            //            [self imageFromVideoWithURL:message.attachmentURL];
        }
        else
        {
            cellImageButton.frame = CGRectMake(cell.frame.size.width-190, 10, 180, 80);
            
            //            [cellImageButton setImage:[UIImage imageWithData:[ChatAttachmentHelperClass sharedInstance].attachmentData] forState:UIControlStateNormal];
        }
        [cellImageButton addTarget:self action:@selector(previewAudio:) forControlEvents:UIControlEventTouchUpInside];
        cellImageButton.accessibilityIdentifier = [NSString stringWithFormat:@"%li",(long)indexPath.row];
        
        [cell addSubview:cellImageButton];
        cell.bubbleColor = -326;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    if (message.attachmentType == kAudio)
    {
        if ([ChatAttachmentHelperClass sharedInstance].audioPlayer.rate)
        {
            [[ChatAttachmentHelperClass sharedInstance].audioPlayer pause];
            [ChatAttachmentHelperClass sharedInstance].audioPlayer = nil;
        }
    }
}

- (void)previewImageInFullScreenMode:(UIButton *)imageBtn
{
    Message *message = [self.messages objectAtIndex:[imageBtn.accessibilityIdentifier integerValue]];
    FullImageViewController *fullImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FullImageViewController"];
    fullImageViewController.currentPhotoIndex = 0;
    fullImageViewController.arrPhotoGallery = @[@{@"pImg":message.attachmentURL}];
    fullImageViewController.fbID = @"";
    [self presentViewController:fullImageViewController animated:YES completion:nil];
}

- (NSString *)AttachmentsFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Attachments"];
    basePath = [basePath stringByAppendingPathComponent:[FacebookUtility sharedObject].fbID];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return basePath;
}

- (void)previewVideo:(UIButton *)btn
{
    Message *message = [self.messages objectAtIndex:[btn.accessibilityIdentifier integerValue]];

    if (!btn.currentImage)
    {
        // Download
         AFURLConnectionOperation *downloadOperation = [[AFURLConnectionOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:message.attachmentURL]]];
        __weak AFURLConnectionOperation *downloadOperationRequest = downloadOperation;
        [downloadOperationRequest setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"totalBytesRead = %lli",totalBytesRead);
            NSLog(@"bytesRead = %lu",(unsigned long)bytesRead);
            NSLog(@"totalBytesExpectedToRead = %lli",totalBytesExpectedToRead);
            [btn setTitle:[NSString stringWithFormat:@"%.0f%%",(((float)totalBytesRead/(float)totalBytesExpectedToRead))*100] forState:UIControlStateNormal];
            
            
            
        }];
        [downloadOperationRequest setCompletionBlock:^{
            NSString *filePath = [[self AttachmentsFolderPath] stringByAppendingPathComponent:[message.attachmentURL lastPathComponent]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:downloadOperationRequest.responseData attributes:nil];
            
            // Create image on Button
            [btn setImage:[self imageFromVideoWithURL:message.attachmentURL] forState:UIControlStateNormal];
            
        }];
        [downloadOperationRequest start];
    }
    else
    {
        // Play
        moviePlayer = [[MPMoviePlayerViewController alloc] init];
        [moviePlayer.moviePlayer setShouldAutoplay:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidFinishedPlaying:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
        moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [moviePlayer.moviePlayer setContentURL:[NSURL URLWithString:message.attachmentURL]];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    }
    
}

- (void)previewAudio:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected)
    {
        // Play Audio
        Message *message = [self.messages objectAtIndex:[btn.accessibilityIdentifier integerValue]];
        [[ChatAttachmentHelperClass sharedInstance] playAudioWithURLString:message.attachmentURL];
    }
    else
    {
        // Stop Audio
        [[ChatAttachmentHelperClass sharedInstance].audioPlayer pause];
    }
}

- (void)moviePlayerDidFinishedPlaying:(NSNotification*)aNotification
{
    [self dismissMoviePlayerViewControllerAnimated];
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
    moviePlayer = nil;
    
}

- (UIImage *)imageFromVideoWithURL:(NSString *)vidURL
{
    NSString *videoPath = [[self AttachmentsFolderPath] stringByAppendingPathComponent:[vidURL lastPathComponent]];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    UIImage *previewImage = [[UIImage alloc] initWithCGImage:imgRef];
    
    // Write to Path
    NSString *fileName = [[[vidURL lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
    
    NSString *filePath = [[self AttachmentsFolderPath] stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImagePNGRepresentation(previewImage) attributes:nil];
    
    return previewImage;
}

- (void)setImageOnButton:(UIButton *)btn WithURL:(NSString *)imageURL WithProgressIndicator:(UIActivityIndicatorView *)activityIndicator
{
    if (!imageURL || !imageURL.length) {
        return;
    }
    __block NSString *bigImageURLString = imageURL;
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    
    NSString *dirPath = [self AttachmentsFolderPath];
    NSString *filePath = [dirPath stringByAppendingPathComponent:[imageURL lastPathComponent]];
    
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (image)
        {
            [btn setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]] forState:UIControlStateNormal];
            
            [activityIndicator stopAnimating];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [self setImageOnButton:btn WithURL:imageURL WithProgressIndicator:activityIndicator];
        }
    }
    else
    {
        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
            
            
            __block NSData *imageData = nil;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error)
             {
                 if (!error)
                 {
                     imageData = data;
                     UIImage *image = nil;
                     data = nil;
                     image = [UIImage imageWithData:imageData];
                     if (image == nil)
                     {
                         image = [UIImage imageNamed:@"Bubble-10"];
                     }
                     
                     [btn setImage:image forState:UIControlStateNormal];
                     [activityIndicator stopAnimating];
                     
                     // Write Image in Document Directory
                     int64_t delayInSeconds = 0.4;
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                     
                     
                     dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
                         if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                         {
                             if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
                             {
                                 [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
                             }
                             
                             [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
                             imageData = nil;
                         }
                     });
                 }
                 
             }];
            
            bigImageURLString = nil;
            
        });
    }
}

#pragma mark - UITableViewDelegate methods

- (void)passEmotionPressed:(UIButton *)btn
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {
        AFNHelper *afnhelper = [AFNHelper new];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,self.recieveFBID,[NSString stringWithFormat:@"%d",self.chatFlag_Mine_State.intValue + 1]] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
        
        [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                [Utils showOKAlertWithTitle:@"Dating" message:response[@"errMsg"]];
                 
             }
             else
             {
                 [Utils showOKAlertWithTitle:@"Dating" message:@"Error Occured, Please Try Again"];
             }
             
         }];
    }
}

- (void)titleForPassEmotionButton:(UIButton *)btn
{
    /*
     (
     {
     fName = Navneet;
     fbId = 10203175848489479;
     flag = 5;
     "flag_initiate" = 1;
     "flag_state" = 2;
     ladt = "2014-10-14 17:25:54";
     pPic = "http://graph.facebook.com/10203175848489479/picture?type=large";
     }
     );
     */
    NSString *strTitle = @"";
    
    if ([self.chatFlag_State intValue] == [self.chatFlag_Mine_State intValue])
    {
        // No Furthur initiation for upcoming emotion
        // Show the Next Emotion What User can Perform with other partener
        
        switch ([self.chatFlag_State intValue])
        {
            case 1:
                strTitle = @"Wave";
                break;
                
            case 2:
                strTitle = @"Smile";
                break;
                
            case 3:
                strTitle = @"Wink";
                break;
                
            default:
                strTitle = @"Not Defined";
                break;
        }
    }
    else
    {
        // Both Partners State is different means any of them went ahead for next emotion.
        // Initiation take place, now calculate both behaviours
        
        // Considering the case of other Partner at priority
        
        [btn setUserInteractionEnabled:YES];
        
        int maxNum = MAX([self.chatFlag_State intValue], [self.chatFlag_Mine_State intValue]);
        
        switch (maxNum)
        {
            case 1:
            {
                if (![self.chatFlag_Initiate boolValue])
                {
                    strTitle = @"Stare Back";
                }
                else
                {
                    strTitle = @"Stared";
                    [btn setUserInteractionEnabled:NO];
                    [btn setBackgroundColor:[UIColor darkGrayColor]];
                }
            }
                break;
            case 2:
            {
                if (![self.chatFlag_Initiate boolValue])
                {
                    strTitle = @"Wave Back";
                }
                else
                {
                    strTitle = @"Waved";
                    [btn setUserInteractionEnabled:NO];
                    [btn setBackgroundColor:[UIColor darkGrayColor]];
                }
            }
                break;
                
            case 3:
            {
                if (![self.chatFlag_Initiate boolValue])
                {
                    strTitle = @"Smile Back";
                }
                else
                {
                    strTitle = @"Smiled";
                    [btn setUserInteractionEnabled:NO];
                    [btn setBackgroundColor:[UIColor darkGrayColor]];
                }
            }
                break;
                
            case 4:
            {
                if (![self.chatFlag_Initiate boolValue])
                {
                    strTitle = @"Wink Back";
                }
                else
                {
                    strTitle = @"Winked";
                    [btn setUserInteractionEnabled:NO];
                    [btn setBackgroundColor:[UIColor darkGrayColor]];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    [btn setTitle:strTitle forState:UIControlStateNormal];
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
        [self.tableViewChat setFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-self.viewChatWindow.frame.size.height-216-64)];
        if (self.tableViewChat.contentSize.height > self.tableViewChat.frame.size.height)
        {
            [self.tableViewChat setContentOffset:CGPointMake(0, self.tableViewChat.contentSize.height-self.tableViewChat.frame.size.height) animated:YES];
        }
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, -216)];
    }];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.attachmentType = kText;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.16 animations:^{
        [self.tableViewChat setFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-44-64)];
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, 0)];
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.16 animations:^{
        [self.tableViewChat setFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-44-64)];
        [self.viewChatWindow setTransform:CGAffineTransformMakeTranslation(0, 0)];
        
    }];
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[MyWebSocket sharedInstance] logOutUserShouldClose:YES];
    
}

@end
