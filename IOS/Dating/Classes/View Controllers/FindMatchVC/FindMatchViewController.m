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
#import "UserProfileDetailViewController.h"
#import "PBJHexagonFlowLayout.h"

@interface FindMatchViewController ()
{
    NSArray *matchedProfilesArray;
    NSInteger currentProfileIndex;
    NSArray *preferncesNameArray;
    NSDictionary *preferencesDict;
    NSTimer *profileTimer;
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
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view.
    
    preferencesDict = [NSDictionary dictionaryWithObjects:@[@"smoker",@"non-vegetarian",@"religious",@"night_owl",@"adventurous",@"traveler",@"possessive",@"talker",@"sleeper",@"gamer",@"romantic",@"trust",@"sexy",@"foodie",@"entrepreneur",@"workaholic",@"gadgetfreak",@"hippy",@"hugger",@"gymrat",@"techie",@"fashionmonger",@"moviebuff",@"tvjunkie",@"shy",@"humour",@"peacelover",@"punctual",@"lazy",@"dreamer",@"flirtatious",@"cuddle"] forKeys:@[@"Smoker",@"Non Vegetarian",@"Religious",@"Night Owl",@"Adventurous",@"Traveller",@"Possesive",@"Talker",@"Sleeper",@"Gamer",@"Romantic",@"Trust",@"Sexy",@"Foodie",@"Entrepreneur",@"Workaholic",@"Gadget Freak",@"Hippy",@"Hugger",@"Gym Rat",@"Techie",@"Fashion Monger",@"Movie Buff",@"TV Junkie",@"Shy",@"Humour",@"Peace Lover",@"Punctual",@"Lazy",@"Dreamer",@"Flirtatious",@"Cuddler"]];

    [self findMatchesList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpCountdownView];
//    [self setupTutorialView];
}

- (void)setUpCountdownView
{
    [self.sfCountdownView setHidden:YES];
    self.sfCountdownView.delegate = self;
    self.sfCountdownView.backgroundAlpha = 0.2;
    self.sfCountdownView.countdownColor = [UIColor whiteColor];
    self.sfCountdownView.countdownFrom = 3;
    self.sfCountdownView.finishText = @"Do it";
}

- (void)setupTutorialView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FindMatch"])
    {
        [self.viewTutorial setHidden:NO];
        CALayer *glowLayer = [CALayer layer];
        glowLayer.shadowColor = [UIColor blackColor].CGColor;
        glowLayer.shadowRadius = 15.0f;
        glowLayer.shadowOpacity = 1.0f;
        glowLayer.shadowOffset = CGSizeZero;
        
        [glowLayer setBounds:CGRectMake(0, 0, 40, 40)];
        [self.viewTutorial.layer addSublayer:glowLayer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileOnLayout
{
    NSDictionary *profileDict = matchedProfilesArray[currentProfileIndex];
    [self commonPreferencesWithOtherUserPreferences:[profileDict[@"prefLifeStyle"] componentsSeparatedByString:@","]];
    preferncesNameArray = [[self commonPreferencesWithOtherUserPreferences:[profileDict[@"prefLifeStyle"] componentsSeparatedByString:@","]] mutableCopy];
    PBJHexagonFlowLayout *flowLayout = [[PBJHexagonFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.itemSize = CGSizeMake(70.0f, 80.0f);
    flowLayout.itemsPerRow = [preferncesNameArray count];
    [self.collectionViewPreferences setCollectionViewLayout:flowLayout];
    [self.collectionViewPreferences setContentOffset:CGPointZero animated:NO];
    [self.collectionViewPreferences reloadData];
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    
    [self setImageOnButton:self.btnProfileImage WithActivityIndicator:self.activityIndicator WithImageURL:[matchedProfilesArray[currentProfileIndex][@"oPic"] firstObject][@"pImg"]];
    [self setUpcomingProfilesInFindMatchesList];
    
    self.lblTimer.text = @"0";
    [self.profileTimer invalidate];
    
    self.profileTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
}

- (NSArray *)commonPreferencesWithOtherUserPreferences:(NSArray *)otherUserPreferences
{
    NSArray *myPreferncesArray = [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserPreferences"] mutableCopy] objectForKey:@"ent_pref_lifestyle"] componentsSeparatedByString:@","];
    NSMutableSet* set1 = [NSMutableSet setWithArray:otherUserPreferences];
    NSMutableSet* set2 = [NSMutableSet setWithArray:myPreferncesArray];
    [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
    
    return [set1 allObjects];
}

- (void)displayTime
{
    if (self.lblTimer.text.intValue > 9)
    {
        [self passProfileButtonPressed:nil];
    }
    else if (self.lblTimer.text.intValue > 6)
    {
        [self.sfCountdownView setHidden:NO];
        [self.sfCountdownView start];
        [self.sfCountdownView updateAppearance];
    }
    else
    {
        [self.lblTimer setText:[NSString stringWithFormat:@"%i",[[self.lblTimer text] intValue]+1]];
    }
    
}

- (void) countdownFinished:(SFCountdownView *)view
{
    [self.sfCountdownView setHidden:YES];
    [self.view setNeedsDisplay];
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
    fullImageViewController.arrPhotoGallery = matchedProfilesArray[currentProfileIndex][@"oPic"];
    fullImageViewController.fbID = matchedProfilesArray[currentProfileIndex][@"fbId"];
    [self presentViewController:fullImageViewController animated:YES completion:nil];
}

- (void)findMatchesList
{
    [self showErrorInProfileView];
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
                         
                         [self showProfileViewWithoutError];
                     }
                     else
                     {
                         [self showErrorInProfileView];
                     }
                     
                 }
                 else
                 {
                     matchedProfilesArray = [NSMutableArray array];
                     [self showErrorInProfileView];
                 }
             }
             else
             {
                 [self showErrorInProfileView];
             }
             
         }];
    }

}

- (void)showProfileViewWithoutError
{
    for (int i = 1; i < 4 ; i++)
    {
        [[self.view viewWithTag:i] setHidden:NO];
    }
    UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:4];
    [errorMsgLabel setHidden:YES];
}

- (void)showErrorInProfileView
{
    for (int i = 1; i < 4 ; i++)
    {
        [[self.view viewWithTag:i] setHidden:YES];
    }
    UILabel *errorMsgLabel = (UILabel *)[self.view viewWithTag:4];
    [errorMsgLabel setHidden:NO];
}

- (IBAction)passProfileButtonPressed:(id)sender
{
    
    currentProfileIndex++;
    if (currentProfileIndex < matchedProfilesArray.count)
    {
        [self removeCacheImages];
        [self setProfileOnLayout];
        [self setUpcomingProfilesInFindMatchesList];
    }
    else
    {
        [self showErrorInProfileView];
        self.lblTimer.text = @"";
        [self.profileTimer invalidate];
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
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self passProfileButtonPressed:nil];
                 });
                 
                 
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
//                     [Utils showOKAlertWithTitle:@"Dating" message:response[@"errMsg"]];
                     [self.lblRequestSent setText:[NSString stringWithFormat:@"You Stared at %@",matchedProfilesArray[currentProfileIndex][@"firstName"]]];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.viewRequestSent setHidden:NO];
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self.viewRequestSent setHidden:YES];
                         });
                     });
                     
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

- (IBAction)btnDIsmissTutorialPressed:(id)sender
{
    [self.viewTutorial setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FindMatch"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UserProfileDetailViewController *userProfileDetailViewController = [segue destinationViewController];
    userProfileDetailViewController.matchedProfilesArray = matchedProfilesArray;
    userProfileDetailViewController.currentProfileIndex = currentProfileIndex;
    [self.profileTimer invalidate];
}

- (void)setUpcomingProfilesInFindMatchesList
{
    for (UIImageView *imageView in self.upcomingProfilesView.subviews)
    {
        [imageView setHidden:YES];
    }
    
    for (NSInteger i = currentProfileIndex; i < MIN(matchedProfilesArray.count, currentProfileIndex+3); i++)
    {
        UIImageView *imageView = (UIImageView *)[self.upcomingProfilesView viewWithTag:i+100+1-currentProfileIndex];
        
        [imageView setImageWithURL:[NSURL URLWithString:[matchedProfilesArray[i][@"oPic"] firstObject][@"pImg"]]];
        
        [imageView setHidden:NO];
        
        if (i == currentProfileIndex)
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] WithCornerRadius:15 WithLineWidth:3 withPathColor:[UIColor greenColor]];
        }
        else
        {
            [Utils configureLayerForHexagonWithView:imageView withBorderColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] WithCornerRadius:15  WithLineWidth:3 withPathColor:[UIColor lightGrayColor]];
        }
        
    }
}

#pragma mark UICollectionView Delegate & Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [preferncesNameArray count];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0 , 0, 0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserQualityCell" forIndexPath:indexPath];
    
    NSString* string = preferncesNameArray[indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    [imageView setImage:[UIImage imageNamed:preferencesDict[string]]];
    
    UILabel *preferenceName = (UILabel *)[cell viewWithTag:102];
    preferenceName.numberOfLines = 2;
    
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    CGSize strSize = [string boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"SegoeUI" size:14]} context:nil].size;
    NSLog(@"%@,%@",string,NSStringFromCGSize(strSize));
    style.minimumLineHeight = 10.0f;
    style.maximumLineHeight = 10.0f;
    style.lineSpacing = 0;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
    
    preferenceName.attributedText = [[NSAttributedString alloc] initWithString:string
                                                                    attributes:attributtes];
    [preferenceName setTextAlignment:NSTextAlignmentCenter];
    if (strSize.width > 68)
    {
        [preferenceName setFont:[UIFont fontWithName:@"SegoeUI" size:9]];
    }
    else
    {
        [preferenceName setFont:[UIFont fontWithName:@"SegoeUI" size:11]];
    }
    
    [preferenceName setAdjustsFontSizeToFitWidth:YES];
    
    [Utils configureLayerForHexagonWithView:cell withBorderColor:[UIColor clearColor] WithCornerRadius:15 WithLineWidth:3 withPathColor:[UIColor clearColor]];
    
    return cell;
}

- (IBAction)btnDismissRequestSentPressed:(id)sender {
}
@end
