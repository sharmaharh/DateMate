//
//  UserProfileDetailViewController.m
//  Dating
//
//  Created by Harsh Sharma on 12/2/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "UserProfileDetailViewController.h"
#import "RecentChatsViewController.h"
#import "FindMatchViewController.h"
#import "PBJHexagonFlowLayout.h"

@interface UserProfileDetailViewController ()
{
    NSDictionary *userProfileDict;
    NSArray *preferncesNameArray;
    NSDictionary *preferencesDict;
}

@end

@implementation UserProfileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    preferencesDict = User_Preferences_Dict;
    
    [self setImagesOnScrollView];
    self.btnStare.layer.borderWidth = 1.0f;
    self.btnStare.layer.cornerRadius = self.btnStare.frame.size.height/2;
    self.btnStare.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.btnStare setHidden:!self.isFromMatches];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImagesOnScrollView
{
    userProfileDict = self.matchedProfilesArray[self.currentProfileIndex];
    self.lblusername.text = userProfileDict[@"firstName"];
    self.lbluserAge.text = [userProfileDict[@"age"] length]?[userProfileDict[@"age"] stringByAppendingString:@"years"]:@"";
    [self.imgViewAstrology setImage:[UIImage imageNamed:[self astrologyIconAccordingToDateofBirth]]];
    self.lblAstrologyName.text = [self astrologyNameAsPerDOB];
    self.imgViewAstrology.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imgViewAstrology.layer.shadowRadius = 15.0f;
    self.imgViewAstrology.layer.shadowOpacity = 1.0f;
    self.imgViewAstrology.layer.shadowOffset = CGSizeZero;
    
    preferncesNameArray = [[userProfileDict[@"prefLifeStyle"] componentsSeparatedByString:@","] mutableCopy];
    PBJHexagonFlowLayout *flowLayout = [[PBJHexagonFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.itemSize = CGSizeMake(90.0f, 100.0f);
    flowLayout.itemsPerRow = [preferncesNameArray count];
    
    [self.collectionViewPreferences setCollectionViewLayout:flowLayout];
    [self initializeScrollView];
    
    for (int i = 0; i < [userProfileDict[@"oPic"] count]; i++)
    {
        UIImageView *profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.scrollViewImages.frame.size.width, 0, self.scrollViewImages.frame.size.width, self.scrollViewImages.frame.size.height)];
        [profileImage setContentMode:UIViewContentModeCenter];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.center = profileImage.center;
        [activityIndicator setHidesWhenStopped:YES];
//        __weak UIImageView *weakImageView = profileImage;
        [self setImageOnImageView:profileImage WithImageURL:userProfileDict[@"oPic"][i][@"url"] WithActivityIndicator:activityIndicator];
        
        [profileImage setClipsToBounds:YES];
        [self.scrollViewImages addSubview:profileImage];
        [self.scrollViewImages addSubview:activityIndicator];
    }
    
    self.scrollViewImages.contentSize = CGSizeMake(self.scrollViewImages.frame.size.width * [userProfileDict[@"oPic"] count], 0);
}

- (void)setImageOnImageView:(UIImageView *)imgView WithImageURL:(NSString *)ImageURL WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    [imgView setContentMode:UIViewContentModeCenter];
    [activityIndicator startAnimating];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:ImageURL withFBID:self.matchedProfilesArray[self.currentProfileIndex][@"fbId"] withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        [activityIndicator stopAnimating];
        [imgView setHidden:NO];
        if (!error)
        {
            [imgView setImage:[Utils scaleImage:image WithRespectToFrame:imgView.frame]];
        }
        else
        {
            [imgView setImage:[UIImage imageNamed:@"Bubble-0"]];
        }
    }];
    
}

- (NSString *)astrologyIconAccordingToDateofBirth
{
    NSArray *dobComponents = [userProfileDict[@"dob"] componentsSeparatedByString:@"-"];
    NSString *astrlogyIconName = @"";
    
    switch ([dobComponents[1] integerValue])
    {
        case 1:
        {
            if ([dobComponents[2] integerValue] > 19)
                astrlogyIconName = @"zodiac_aquarius";
            
            else
                astrlogyIconName = @"zodiac_capricorn";

        }
            break;
            
        case 2:
        {
            if ([dobComponents[2] integerValue] > 18)
                astrlogyIconName = @"zodiac_pisces";
            
            else
                astrlogyIconName = @"zodiac_aquarius";
            
        }
            break;
            
        case 3:
        {
            if ([dobComponents[2] integerValue] > 20)
                astrlogyIconName = @"zodiac_aries";
            
            else
                astrlogyIconName = @"zodiac_pisces";
            
        }
            break;
            
        case 4:
        {
            if ([dobComponents[2] integerValue] > 19)
                astrlogyIconName = @"zodiac_taurus";
            
            else
                astrlogyIconName = @"zodiac_aries";
            
        }
            break;
            
        case 5:
        {
            if ([dobComponents[2] integerValue] > 20)
                astrlogyIconName = @"zodiac_gemini";
            
            else
                astrlogyIconName = @"zodiac_taurus";
            
        }
            break;
            
        case 6:
        {
            if ([dobComponents[2] integerValue] > 20)
                astrlogyIconName = @"zodiac_cancer";
            
            else
                astrlogyIconName = @"zodiac_gemini";
            
        }
            break;
            
        case 7:
        {
            if ([dobComponents[2] integerValue] > 22)
                astrlogyIconName = @"zodiac_leo";
            
            else
                astrlogyIconName = @"zodiac_cancer";
            
        }
            break;
            
        case 8:
        {
            if ([dobComponents[2] integerValue] > 22)
                astrlogyIconName = @"zodiac_virgo";
            
            else
                astrlogyIconName = @"zodiac_leo";
            
        }
            break;
            
        case 9:
        {
            if ([dobComponents[2] integerValue] > 22)
                astrlogyIconName = @"zodiac_libra";
            
            else
                astrlogyIconName = @"zodiac_virgo";
            
        }
            break;
            
        case 10:
        {
            if ([dobComponents[2] integerValue] > 22)
                astrlogyIconName = @"zodiac_scorpio";
            
            else
                astrlogyIconName = @"zodiac_libra";
            
        }
            break;
            
        case 11:
        {
            if ([dobComponents[2] integerValue] > 21)
                astrlogyIconName = @"zodiac_sagittarius";
            
            else
                astrlogyIconName = @"zodiac_scorpio";
            
        }
            break;
            
        case 12:
        {
            if ([dobComponents[2] integerValue] > 21)
                astrlogyIconName = @"zodiac_capricorn";
            
            else
                astrlogyIconName = @"zodiac_sagittarius";
            
        }
            break;
            
        default:
            break;
    }
    return astrlogyIconName;
}

- (NSString *)astrologyNameAsPerDOB
{
    NSString *iconImageName = [self astrologyIconAccordingToDateofBirth];
    iconImageName = [[iconImageName substringFromIndex:7] capitalizedString];
    return iconImageName;
}

- (void)initializeScrollView
{
    for (UIView *view in self.scrollViewImages.subviews)
    {
        [view removeFromSuperview];
    }
    [self.scrollViewImages setContentOffset:CGPointZero];
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
    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
    NSString* string = preferncesNameArray[indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    [imageView setImage:[UIImage imageNamed:preferencesDict[string]]];
    
    UILabel *preferenceName = (UILabel *)[cell viewWithTag:2];
    preferenceName.numberOfLines = 2;
    
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    CGSize strSize = [string boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"SegoeUI" size:14]} context:nil].size;
    style.minimumLineHeight = 12.0f;
    style.maximumLineHeight = 12.0f;
    style.lineSpacing = 0;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
    
    preferenceName.attributedText = [[NSAttributedString alloc] initWithString:string
                                                                    attributes:attributtes];
    [preferenceName setTextAlignment:NSTextAlignmentCenter];
    if (strSize.width > 68)
    {
        [preferenceName setFont:[UIFont fontWithName:@"SegoeUI" size:12]];
    }
    else
    {
        [preferenceName setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
    }
    
    [preferenceName setAdjustsFontSizeToFitWidth:YES];
    
    [Utils configureLayerForHexagonWithView:cell withBorderColor:[UIColor clearColor] WithCornerRadius:20 WithLineWidth:3 withPathColor:[UIColor clearColor]];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnPassPressed:(id)sender
{
    [self removeCacheImages];
    self.currentProfileIndex++;
    if (self.currentProfileIndex < self.matchedProfilesArray.count)
    {
        [self setImagesOnScrollView];
        [self.collectionViewPreferences reloadData];
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

- (IBAction)btnBackPressed:(id)sender
{
    if ([[[self.navigationController viewControllers] objectAtIndex:self.navigationController.viewControllers.count-2] isKindOfClass:[FindMatchViewController class]])
    {
        FindMatchViewController *findMatchVC = [[self.navigationController viewControllers] objectAtIndex:self.navigationController.viewControllers.count-2];
        [findMatchVC.profileTimer invalidate];
        findMatchVC.profileTimer = nil;
        findMatchVC.profileTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:findMatchVC selector:@selector(displayTime) userInfo:nil repeats:YES];
        
        NSLog(@"Current LABEL TIME = %@",findMatchVC.lblTimer.text);
        
        if (findMatchVC.lblTimer.text.intValue < 4 && findMatchVC.lblTimer.text.intValue > -1)
        {
            NSLog(@"Current Countdown = %i",findMatchVC.sfCountdownView.currentCountdownValue);
            if (findMatchVC.sfCountdownView.currentCountdownValue)
            {
                [findMatchVC.sfCountdownView setCountdownFrom:findMatchVC.sfCountdownView.currentCountdownValue];
                [findMatchVC.sfCountdownView start];
                [findMatchVC.lblTimer setHidden:YES];
            }
            else
            {
                [findMatchVC countdownFinished:findMatchVC.sfCountdownView];
            }
            
            
        }
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeCacheImages
{
    NSString *filePath = [FileManager ProfileImageFolderPathWithFBID:self.matchedProfilesArray[self.currentProfileIndex][@"fbId"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
}

- (IBAction)btnStarePressed:(id)sender
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    else
    {
        AFNHelper *afnhelper = [AFNHelper new];
        NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,self.matchedProfilesArray[self.currentProfileIndex][@"fbId"],@"1"] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
        
        [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
         {
             if (!error)
             {
                 
                 if ([response[@"errMsg"] isEqualToString:@"Congrats! You got a match"]) {
                     // Now Winked Back, Start Conversation
                     [[Utils sharedInstance] openAlertViewWithTitle:@"Dating" message:response[@"errMsg"] buttons:@[@"Cancel",@"Chat"] completion:^(UIAlertView *alert, NSInteger buttonIndex)
                      {
                          [self processPreviuosScreen];
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
                     [self.lblRequestSent setText:[NSString stringWithFormat:@"You Stared at %@",self.matchedProfilesArray[self.currentProfileIndex][@"firstName"]]];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.viewRequestSent setHidden:NO];
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self.viewRequestSent setHidden:YES];
                             [self processPreviuosScreen];
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

- (void)processPreviuosScreen
{
    FindMatchViewController *findMatchVC = [[self.navigationController viewControllers] objectAtIndex:self.navigationController.viewControllers.count-2];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [findMatchVC passProfileButtonPressed:nil];
}

@end
