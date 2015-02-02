//
//  UserProfileDetailViewController.h
//  Dating
//
//  Created by Harsh Sharma on 12/2/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileDetailViewController : UIViewController

@property (strong, nonatomic) NSArray *matchedProfilesArray;
@property (assign, nonatomic) NSInteger currentProfileIndex;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewProfile;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewImages;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControlImages;


@property (strong, nonatomic) IBOutlet UIView *viewUserInfo;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAstrology;
@property (strong, nonatomic) IBOutlet UILabel *lblusername;
@property (strong, nonatomic) IBOutlet UILabel *lbluserAge;
@property (strong, nonatomic) IBOutlet UILabel *lblAstrologyName;
@property (strong, nonatomic) IBOutlet UILabel *lblUserStatus;


- (IBAction)btnBackPressed:(id)sender;

- (IBAction)btnStarePressed:(id)sender;


@property (strong, nonatomic) IBOutlet UIButton *btnStare;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewPreferences;
@property (strong, nonatomic) IBOutlet UIView *viewRequestSent;
@property (strong, nonatomic) IBOutlet UILabel *lblRequestSent;

@property (assign, nonatomic) BOOL isFromMatches;
@end
