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
{
    NSArray *preferenceImagesArray;
    NSArray *preferncesNameArray;
}
@end

@implementation SelectTastesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PBJHexagonFlowLayout *flowLayout = [[PBJHexagonFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsZero;
//    flowLayout.minimumInteritemSpacing = 10.0f;
//    flowLayout.minimumLineSpacing = 10.0f;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.itemSize = CGSizeMake(90.0f, 100.0f);
    flowLayout.itemsPerRow = 8;
    self.preferencesArray = [NSMutableArray array];

    preferncesNameArray = @[@"Smoker",@"Non Vegetarian",@"Religious",@"Night Owl",@"Adventurous",@"Traveller",@"Possesive",@"Talker",@"Sleeper",@"Gamer",@"Romantic",@"Trust",@"Sexy",@"Foodie",@"Entrepreneur",@"Workaholic",@"Gadget Freak",@"Hippy",@"Hugger",@"Gym Rat",@"Techie",@"Fashion Monger",@"Movie Buff",@"TV Junkie",@"Shy",@"Humour",@"Peace Lover",@"Punctual",@"Lazy",@"Dreamer",@"Flirtatious",@"Cuddler"];
    
    preferenceImagesArray = @[@"smoker",@"non-vegetarian",@"religious",@"night_owl",@"adventurous",@"traveler",@"possessive",@"talker",@"sleeper",@"gamer",@"romantic",@"trust",@"sexy",@"foodie",@"entrepreneur",@"workaholic",@"gadgetfreak",@"hippy",@"hugger",@"gymrat",@"techie",@"fashionmonger",@"moviebuff",@"tvjunkie",@"shy",@"humour",@"peacelover",@"punctual",@"lazy",@"dreamer",@"flirtatious",@"cuddle"];
    
    [self.collectionViewPreferences enableCustomScrollIndicatorsWithScrollIndicatorType:JMOScrollIndicatorTypeClassic positions:JMOHorizontalScrollIndicatorPositionBottom color:[UIColor whiteColor]];
    [self.collectionViewPreferences setCollectionViewLayout:flowLayout];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionView Delegate & Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [preferncesNameArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserQualityCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    [imageView setImage:[UIImage imageNamed:preferenceImagesArray[indexPath.row%preferenceImagesArray.count]]];
    
    UILabel *preferenceName = (UILabel *)[cell viewWithTag:2];
    preferenceName.numberOfLines = 2;
    NSString* string = preferncesNameArray[indexPath.row];
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    CGSize strSize = [string boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"SegoeUI" size:14]} context:nil].size;
    NSLog(@"%@,%@",string,NSStringFromCGSize(strSize));
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
    NSLog(@"Selected Cell Index = %li",(long)indexPath.row);
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
        [Utils showOKAlertWithTitle:@"Dating" message:@"No Internet Connection!"];
    }
    
    if (self.preferencesArray.count < 5)
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"Please select atleast 5 preferences to proceed"];
        return;
    }
    
    for (NSInteger i = 0; i < self.preferencesArray.count; i++)
    {
        [self.preferencesArray replaceObjectAtIndex:i withObject:[preferncesNameArray objectAtIndex:[[self.preferencesArray objectAtIndex:i] intValue]]];
    }
    
    [appDelegate.userPreferencesDict setObject:[self.preferencesArray componentsJoinedByString:@","] forKey:@"ent_pref_lifestyle"];
    
    AFNHelper *afnhelper = [AFNHelper new];
    [afnhelper getDataFromPath:@"updatePreferences" withParamData:appDelegate.userPreferencesDict withBlock:^(id response, NSError *error) {

        if (!error)
        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dating" message:@"Preferences updated successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:appDelegate.userPreferencesDict forKey:@"UserPreferences"];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"LoginPersistingClass"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
            appDelegate.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
            
            RearMenuViewController *rearMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
            appDelegate.revealController = [[ResideMenuViewController alloc] initWithContentViewController:appDelegate.frontNavigationController leftMenuViewController:rearMenuViewController rightMenuViewController:nil];
            
            [appDelegate.window setRootViewController:appDelegate.revealController];
            
            [appDelegate.window makeKeyAndVisible];
            
        }
        else{
            //                 [pi hideProgressIndicator];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
        }
        
        
    }];
    
    
}

-(void)dealloc
{
    [self.collectionViewPreferences disableCustomScrollIndicator];
}

@end
