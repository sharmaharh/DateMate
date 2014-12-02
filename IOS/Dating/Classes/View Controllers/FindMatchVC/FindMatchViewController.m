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
    
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    
    NSArray *userProfileImagesArray = matchedProfilesArray[currentProfileIndex][@"pPic"];
    
    [self setImageOnButton:self.btnProfileImage WithActivityIndicator:self.activityIndicator WithImageURL:[userProfileImagesArray firstObject][@"pImg"]];
    [self setUpcomingProfilesInFindMatchesList];
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
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (image)
        {
            [btn setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]] forState:UIControlStateNormal];
            [activityIndicator stopAnimating];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [self setImageOnButton:btn WithActivityIndicator:activityIndicator WithImageURL:ImageURL];
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
                }
                
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
                         [self.btnPassProfile setHidden:NO];
                         [[self.view viewWithTag:2] setHidden:NO];
                     }
                     else
                     {
                         for (UIView *view in self.view.subviews)
                         {
                             [view setHidden:YES];
                         }
                         UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:100];
                         [errorMsgLabel setHidden:NO];
                         
                         [self.btnPassProfile setHidden:YES];
                         [[self.view viewWithTag:2] setHidden:YES];
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
                     
                     [self.btnPassProfile setHidden:YES];
                     [[self.view viewWithTag:2] setHidden:YES];
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
                 
                 [self.btnPassProfile setHidden:YES];
                 [[self.view viewWithTag:2] setHidden:YES];
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
        [self setUpcomingProfilesInFindMatchesList];
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
    
}

- (IBAction)passEmotionsButtonPressed:(id)sender
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        AFNHelper *afnhelper = [AFNHelper new];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[currentProfileIndex][@"fbId"],@"1"] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
        
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
                             [appDelegate.revealController setContentViewController:appDelegate.frontNavigationController animated:NO];
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

- (IBAction)btnProfileDetailPressed:(id)sender
{
    [self performSegueWithIdentifier:@"matchedProfileToProfileDetailIdentifier" sender:nil];
}

- (void)setUpcomingProfilesInFindMatchesList
{
    for (UIImageView *imageView in self.upcomingProfilesView.subviews)
    {
        [imageView setHidden:YES];
    }
    
    for (int i = currentProfileIndex; i < MIN(matchedProfilesArray.count, currentProfileIndex+3); i++)
    {
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-currentProfileIndex];
        
        [imageView setImageWithURL:[NSURL URLWithString:matchedProfilesArray[i][@"pPic"][0][@"pImg"]]];
        
        [imageView setHidden:NO];
        
        if (i == currentProfileIndex)
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor blueColor]];
        }
        else
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor lightGrayColor]];
        }
        
    }
}

@end
