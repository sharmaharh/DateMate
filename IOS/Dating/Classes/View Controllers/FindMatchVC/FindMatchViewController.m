//
//  FindMatchViewController.m
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "FindMatchViewController.h"
#import "RecentChatsViewController.h"

@interface FindMatchViewController ()
{
    NSArray *matchedProfilesArray;
    NSInteger currentProfileIndex;
}
@end

@implementation FindMatchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self findMatchesList];
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileOnLayout
{
    NSDictionary *profileDict = matchedProfilesArray[currentProfileIndex];
    for (int i = 1; i < 4; i++)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.selected = NO;
    }
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    
    [self setImagesOnScrollView];
    
//    [self.profileImageView setImage:nil];
//    [self.activityIndicator startAnimating];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileDict[@"pPic"][0][@"pImg"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        [self.activityIndicator stopAnimating];
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        if (!connectionError)
//        {
//            UIImage *image = [UIImage imageWithData:data];
//            if (image) {
//                [self.profileImageView setImage:image];
//            }
//            
//        }
//        else
//        {
//            [Utils showOKAlertWithTitle:@"Dating" message:@"Some Error Occured, Please Try Again."];
//        }
//    }];
    
}

- (void)setImagesOnScrollView
{
    NSArray *userProfileImagesArray = matchedProfilesArray[currentProfileIndex][@"pPic"];
    CGFloat x = 3;
    for (int i = 0; i < [userProfileImagesArray count]; i++)
    {
        
        UIButton *btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnImage setFrame:CGRectMake(x, 0, self.scrollViewImages.frame.size.width-6, self.scrollViewImages.frame.size.height)];
        btnImage.tag = i+1;
        [btnImage.imageView setContentMode:UIViewContentModeCenter];
        [btnImage addTarget:self action:@selector(showFullPicture:) forControlEvents:UIControlEventTouchUpInside];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.scrollViewImages.frame.size.width-37)/2, (self.scrollViewImages.frame.size.height-37)/2, 37, 37)];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setTintColor:[UIColor colorWithRed:255.0f/255.0f green:205.0f/255.0f blue:7.0f/255.0f alpha:1]];
        [indicatorView setHidesWhenStopped:YES];
        [self.scrollViewImages addSubview:btnImage];
        [self.scrollViewImages addSubview:indicatorView];
        [self setImageOnButton:btnImage WithActivityIndicator:indicatorView WithImageURL:userProfileImagesArray[i][@"pImg"]];
        x += 300;
    }
    self.scrollViewImages.contentSize = CGSizeMake([userProfileImagesArray count]*self.scrollViewImages.frame.size.width, 0);
    
}

- (void)setImageOnButton:(UIButton *)btn WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator WithImageURL:(NSString *)ImageURL
{
    //profileDict[@"pPic"][0][@"pImg"]
    [activityIndicator startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ImageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [activityIndicator stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!connectionError)
        {
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                [btn setImage:image forState:UIControlStateNormal];
            }
            
        }
        else
        {
            [Utils showOKAlertWithTitle:@"Dating" message:@"Some Error Occured, Please Try Again."];
        }
    }];
}

- (void)showFullPicture:(UIButton *)btn
{
    
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

- (void)findMatchesList
{
    matchedProfilesArray = [NSMutableArray array];
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"findMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID} mutableCopy] withBlock:^(id response, NSError *error)
         {
             
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             if (![[response objectForKey:@"errFlag"] boolValue])
             {
                 if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
                 {
                     matchedProfilesArray = [response objectForKey:@"matches"];
                     if ([matchedProfilesArray count])
                     {
                         [self setProfileOnLayout];
                         for (UIView *view in self.view.subviews)
                         {
                             [view setHidden:NO];
                         }
                         UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                         [errorMsgLabel setHidden:YES];
                     }
                     else
                     {
                         for (UIView *view in self.view.subviews)
                         {
                             [view setHidden:YES];
                         }
                         UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                         [errorMsgLabel setHidden:NO];
                     }
                     
                 }
                 else
                 {
                     matchedProfilesArray = [NSMutableArray array];
                     for (UIView *view in self.view.subviews)
                     {
                         [view setHidden:YES];
                     }
                     UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                     [errorMsgLabel setHidden:NO];
                 }
             }
             else
             {
                 for (UIView *view in self.view.subviews)
                 {
                     [view setHidden:YES];
                 }
                 UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                 [errorMsgLabel setHidden:NO];
             }
             
         }];
    }

}

- (IBAction)passProfileButtonPressed:(id)sender
{
    currentProfileIndex++;
    if (currentProfileIndex < matchedProfilesArray.count)
    {
        [self setProfileOnLayout];
        
    }
    else
    {
        
        for (UIView *view in self.view.subviews)
        {
            [view setHidden:YES];
        }
        UILabel *errorLabel = (UILabel *)[self.view viewWithTag:100];
        [errorLabel setHidden:NO];
        
//        [Utils showOKAlertWithTitle:@"Dating" message:@"Sorry, Boss No More Entry Available"];
    }
    
}

- (void)passProfile
{
//    AFNHelper *afnhelper = [AFNHelper new];
//    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[currentProfileIndex][@"fbId"],[NSString stringWithFormat:@"%lu",(long)emotionsButton.tag]] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
//    
//    [afnhelper getDataFromPath:@"getProfileMatches" withParamData:requestDic withBlock:^(id response, NSError *error)
//     {
//         if (!error)
//         {
//             [self passProfileButtonPressed:nil];
//             
//             if ([response[@"errMsg"] isEqualToString:@"Congrats! You got a match"]) {
//                 // Now Winked Back, Start Conversation
//                 [[Utils sharedInstance] openAlertViewWithTitle:@"Dating" message:response[@"errMsg"] buttons:@[@"Cancel",@"Chat"] completion:^(UIAlertView *alert, NSInteger buttonIndex)
//                  {
//                      if (buttonIndex)
//                      {
//                          
//                          UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//                          RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
//                          appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
//                          recentChatViewController.isFromPush = NO;
//                          [appDelegate.revealController pushFrontViewController:appDelegate.frontNavigationController animated:NO];
//                          ChatViewController *chatViewConrtroller = [ChatViewController sharedChatInstance];
//                          chatViewConrtroller.recieveFBID = response[@"uFbId"];
//                          chatViewConrtroller.userName = response[@"uName"];
//                          [appDelegate.frontNavigationController pushViewController:chatViewConrtroller animated:YES];
//                      }
//                      
//                  }];
//                 
//             }
//             else
//             {
//                 [Utils showOKAlertWithTitle:@"Dating" message:response[@"errMsg"]];
//             }
//             
//             
//         }
//         else
//         {
//             [Utils showOKAlertWithTitle:@"Dating" message:@"Error Occured, Please Try Again"];
//         }
//         
//         //         emotionsButton.selected = YES;
//         
//         //         if ([[response objectForKey:@"errFlag"] boolValue])
//         //         {
//         //             if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
//         //             {
//         //                 matchedProfilesArray = [response objectForKey:@"matches"];
//         //                 [self setProfileOnLayout];
//         //             }
//         //             else
//         //             {
//         //                 matchedProfilesArray = [NSMutableArray array];
//         //             }
//         //         }
//         
//     }];
//}
}

- (IBAction)passEmotionsButtonPressed:(id)sender
{
    UIButton *emotionsButton = (UIButton *)sender;
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        AFNHelper *afnhelper = [AFNHelper new];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[currentProfileIndex][@"fbId"],[NSString stringWithFormat:@"%lu",(long)emotionsButton.tag]] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
        
        [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 [self passProfileButtonPressed:nil];
                 
                 if ([response[@"errMsg"] isEqualToString:@"Congrats! You got a match"]) {
                     // Now Winked Back, Start Conversation
                     [[Utils sharedInstance] openAlertViewWithTitle:@"Dating" message:response[@"errMsg"] buttons:@[@"Cancel",@"Chat"] completion:^(UIAlertView *alert, NSInteger buttonIndex)
                     {
                         if (buttonIndex)
                         {
                             
                             UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                             RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                             appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
                             recentChatViewController.isFromPush = NO;
                             [appDelegate.revealController pushFrontViewController:appDelegate.frontNavigationController animated:NO];
                             ChatViewController *chatViewConrtroller = [ChatViewController sharedChatInstance];
                             chatViewConrtroller.recieveFBID = response[@"uFbId"];
                             chatViewConrtroller.userName = response[@"uName"];
                             [appDelegate.frontNavigationController pushViewController:chatViewConrtroller animated:YES];
                         }
                         
                     }];
                     
                 }
                 else
                 {
                     [Utils showOKAlertWithTitle:@"Dating" message:response[@"errMsg"]];
                 }
                 
                 
             }
             else
             {
                 [Utils showOKAlertWithTitle:@"Dating" message:@"Error Occured, Please Try Again"];
             }
             
             //         emotionsButton.selected = YES;
             
             //         if ([[response objectForKey:@"errFlag"] boolValue])
             //         {
             //             if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
             //             {
             //                 matchedProfilesArray = [response objectForKey:@"matches"];
             //                 [self setProfileOnLayout];
             //             }
             //             else
             //             {
             //                 matchedProfilesArray = [NSMutableArray array];
             //             }
             //         }
             
         }];
    }
    
}
- (IBAction)btnRevealPressed:(id)sender
{
    [self.revealViewController revealToggle:self];
}

#pragma mark UIScrollViewDelegate

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    NSInteger currentPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
//    
//    NSArray *imagesArray = matchedProfilesArray[currentProfileIndex][@"pPic"];
//    
//    if (currentPageIndex == 0 && imagesArray.count > 1)
//    {
//        UIButton *nextBtnImage = (UIButton *)[scrollView viewWithTag:currentPageIndex+2];
//        
//    }
//    else if (currentPageIndex == [matchedProfilesArray[currentProfileIndex][@"pPic"] count]-1)
//    {
//        UIButton *previousBtnImage = (UIButton *)[self.scrollViewImages viewWithTag:currentPageIndex];
//        
//    }
//    else
//    {
//        
//    }
//        
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    
//}

@end
