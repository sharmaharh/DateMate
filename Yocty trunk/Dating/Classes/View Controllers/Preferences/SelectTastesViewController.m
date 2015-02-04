//
//  SelectTastesViewController.m
//  Dating
//
//  Created by Harsh Sharma on 12/2/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "SelectTastesViewController.h"
#import "PBJHexagonFlowLayout.h"
#import "FindMatchViewController.h"
#import "RearMenuViewController.h"

@interface SelectTastesViewController ()

@property (nonatomic, strong) UIView *hsIndicatorView;
@end

@implementation SelectTastesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeView];
}

- (void)customizeView
{
    PBJHexagonFlowLayout *flowLayout = [[PBJHexagonFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.itemSize = CGSizeMake(90.0f, 100.0f);
    flowLayout.itemsPerRow = 8;
    self.preferencesArray = [NSMutableArray array];
    
    _hsIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollIndicatorBG.frame.origin.x, self.scrollIndicatorBG.frame.origin.y, 100, self.scrollIndicatorBG.frame.size.height)];
    _hsIndicatorView.backgroundColor = [UIColor whiteColor];
    [_hsIndicatorView.layer setCornerRadius:_hsIndicatorView.frame.size.height/2];
    [_scrollIndicatorBG.layer setCornerRadius:_scrollIndicatorBG.frame.size.height/2];
    
    [self.view addSubview:_hsIndicatorView];
    [self.btnContinue.layer setCornerRadius:self.btnContinue.frame.size.height/2];
    [self.btnContinue.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.btnContinue.layer setBorderWidth:1.0f];
    
    [self.collectionViewPreferences setCollectionViewLayout:flowLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionView Delegate & Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [User_Preferences_Dict count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserQualityCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    [imageView setImage:[UIImage imageNamed:User_Preferences_Dict[[User_Preferences_Dict allKeys][indexPath.row]]]];
    
    UILabel *preferenceName = (UILabel *)[cell viewWithTag:2];
    preferenceName.numberOfLines = 2;
    NSString* string = [User_Preferences_Dict allKeys][indexPath.row];
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
    if ([self.preferencesArray containsObject:[NSNumber numberWithInteger:indexPath.row]])
    {
        cell.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:229.0f/255.0f alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
    }
    
    [Utils configureLayerForHexagonWithView:cell withBorderColor:[UIColor clearColor] WithCornerRadius:20 WithLineWidth:3 withPathColor:[UIColor clearColor]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (![self.preferencesArray containsObject:[NSNumber numberWithInteger:indexPath.row]])
    {
        // Make Selection
        cell.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:229.0f/255.0f alpha:1];
        [self.preferencesArray addObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    else
    {
        // Deselect it
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
        [self.preferencesArray removeObject:[NSNumber numberWithInteger:indexPath.row]];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnProceedPressed:(id)sender
{
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
        return;
    }
    
    if (self.preferencesArray.count < 5)
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:@"Please select atleast 5 preferences to proceed"];
        return;
    }
    NSMutableArray *reqPreferencesArray = [NSMutableArray arrayWithArray:self.preferencesArray];
    for (NSInteger i = 0; i < self.preferencesArray.count; i++)
    {
        [reqPreferencesArray replaceObjectAtIndex:i withObject:[[User_Preferences_Dict allKeys] objectAtIndex:[[self.preferencesArray objectAtIndex:i] intValue]]];
    }
    [sender setEnabled:NO];
    [[Utils sharedInstance] startHSLoaderInView:self.view];
    
    [appDelegate.userPreferencesDict setObject:[reqPreferencesArray componentsJoinedByString:@","] forKey:@"ent_pref_lifestyle"];
    
    AFNHelper *afnhelper = [AFNHelper new];
    [afnhelper getDataFromPath:@"updatePreferences" withParamData:appDelegate.userPreferencesDict withBlock:^(id response, NSError *error) {
        [sender setEnabled:YES];
        [[Utils sharedInstance] stopHSLoader];
        if (!error)
        {
            [[NSUserDefaults standardUserDefaults] setObject:appDelegate.userPreferencesDict forKey:@"UserPreferences"];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"LoginPersistingClass"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
                appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
                [appDelegate.frontNavigationController setNavigationBarHidden:YES];
                
                
                appDelegate.revealController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResideMenuViewController"];
                appDelegate.revealController.contentViewController = appDelegate.frontNavigationController;
                [appDelegate.window setRootViewController:appDelegate.revealController];
                
                [appDelegate.window makeKeyAndVisible];
            });
            
            
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_Alert_Title message:@"Sorry, something we missed it, Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
    }];
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentWidth = scrollView.contentSize.width;
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollWidth = self.scrollIndicatorBG.frame.size.width;
    CGFloat indicatorWidth = _hsIndicatorView.frame.size.width;
    
    if (contentOffsetX <= 0)
    {
        CGRect IndicatorFrame = _hsIndicatorView.frame;
        IndicatorFrame.origin.x = self.scrollIndicatorBG.frame.origin.x;
        _hsIndicatorView.frame = IndicatorFrame;
        return;
    }

    if (contentOffsetX >= scrollView.contentSize.width - scrollView.frame.size.width)
    {
        CGRect IndicatorFrame = _hsIndicatorView.frame;
        IndicatorFrame.origin.x = self.scrollIndicatorBG.frame.origin.x + self.scrollIndicatorBG.frame.size.width - indicatorWidth;
        _hsIndicatorView.frame = IndicatorFrame;
        return;
    }
    
    CGFloat x = (contentOffsetX + 10) * (scrollWidth-indicatorWidth) / (contentWidth-scrollWidth) + self.scrollIndicatorBG.frame.origin.x;
    
    CGRect IndicatorFrame = _hsIndicatorView.frame;
    IndicatorFrame.origin.x = x;
    _hsIndicatorView.frame = IndicatorFrame;
}

@end
