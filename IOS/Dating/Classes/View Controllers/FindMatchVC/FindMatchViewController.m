//
//  FindMatchViewController.m
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "FindMatchViewController.h"
#import "RecentChatsViewController.h"
#import "FullImageViewController.h"

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
    [self findMatchesList];
}

- (void)viewWillAppear:(BOOL)animated
{
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
    
    UIButton *button = (UIButton *)[self.view viewWithTag:1];
    button.selected = NO;
    
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    
    [self setImagesOnScrollView];
    
}

- (void)setImagesOnScrollView
{
    NSArray *userProfileImagesArray = matchedProfilesArray[currentProfileIndex][@"pPic"];
    [self removeAllSubViewsFromScrollView];
    [self.pageControl setHidden:NO];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = userProfileImagesArray.count;
    CGFloat x = 3;
    for (int i = 0; i < [userProfileImagesArray count]; i++)
    {
        
        UIButton *btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnImage setFrame:CGRectMake(x, 0, self.scrollViewImages.frame.size.width-6, self.scrollViewImages.frame.size.height)];
        btnImage.tag = i+1;
        [btnImage.imageView setContentMode:UIViewContentModeScaleAspectFill];
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

- (void)removeAllSubViewsFromScrollView
{
    for (id View in self.scrollViewImages.subviews)
    {
        [View removeFromSuperview];
    }
}

- (void)setImageOnButton:(UIButton *)btn WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator WithImageURL:(NSString *)ImageURL
{
    if (!ImageURL || !ImageURL.length) {
        return;
    }
    __block NSString *bigImageURLString = ImageURL;
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    
    NSString *dirPath = [self ProfileImageFolderPathWithFBID:matchedProfilesArray[currentProfileIndex][@"fbId"]];
    NSString *filePath = [dirPath stringByAppendingPathComponent:[ImageURL lastPathComponent]];
    
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        [btn setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]] forState:UIControlStateNormal];
        [activityIndicator stopAnimating];
    }
    else
    {
        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
            
            
            __block NSData *imageData = nil;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
    
                imageData = data;
                UIImage *image = nil;
                data = nil;
                image = [UIImage imageWithData:imageData];
                if (image == nil)
                {
                    image = [UIImage imageNamed:@"Bubble-0"];
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
                
            }];
            
            bigImageURLString = nil;
            
            
        });
    }
    
}

- (NSString *)ProfileImageFolderPathWithFBID:(NSString *)fbID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Profile_Images"];
    basePath = [basePath stringByAppendingPathComponent:matchedProfilesArray[currentProfileIndex][@"fbId"]];
    return basePath;
}

- (void)showFullPicture:(UIButton *)btn
{
    FullImageViewController *fullImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FullImageViewController"];
    fullImageViewController.currentPhotoIndex = btn.tag-1;
    fullImageViewController.arrPhotoGallery = matchedProfilesArray[currentProfileIndex][@"pPic"];
    fullImageViewController.fbID = matchedProfilesArray[currentProfileIndex][@"fbId"];
    [self presentViewController:fullImageViewController animated:YES completion:nil];
}

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
    [self removeCacheImages];
    currentProfileIndex++;
    if (currentProfileIndex < matchedProfilesArray.count)
    {
        [self setProfileOnLayout];
        [self downloadNextProfileImagesToProcessFastly];
    }
    else
    {
        
        for (UIView *view in self.view.subviews)
        {
            [view setHidden:YES];
        }
        UILabel *errorLabel = (UILabel *)[self.view viewWithTag:100];
        [errorLabel setHidden:NO];

    }
    
}

- (void)removeCacheImages
{
    NSString *filePath = [self ProfileImageFolderPathWithFBID:matchedProfilesArray[currentProfileIndex][@"fbId"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    [self.scrollViewImages setContentOffset:CGPointZero];
    
}

- (void)downloadNextProfileImagesToProcessFastly
{
//    NSString *filePath = [self ProfileImageFolderPathWithFBID:matchedProfilesArray[currentProfileIndex + 1][@"fbId"]];
}

- (void)passProfile
{
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
             
         }];
    }
    
}
- (IBAction)btnRevealPressed:(id)sender
{
    [self.revealViewController revealToggle:self];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger currentPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    self.pageControl.currentPage = currentPageIndex;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    self.pageControl.currentPage = currentPageIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger currentPageIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    self.pageControl.currentPage = currentPageIndex;
}

@end
