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
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewImages;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAstrology;
@property (strong, nonatomic) IBOutlet UILabel *lblusername;
@property (strong, nonatomic) IBOutlet UILabel *lbluserAge;
@property (strong, nonatomic) IBOutlet UILabel *lblAstrologyName;

- (IBAction)btnPassPressed:(id)sender;
- (IBAction)btnBackPressed:(id)sender;

- (IBAction)btnStarePressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnPass;
@property (strong, nonatomic) IBOutlet UIButton *btnStare;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewPreferences;
@property (strong, nonatomic) IBOutlet UIView *viewRequestSent;
@property (strong, nonatomic) IBOutlet UILabel *lblRequestSent;

@end
