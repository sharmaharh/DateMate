//
//  PreferencesViewController.h
//  Dating
//
//  Created by Harsh Sharma on 05/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferencesViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>


- (IBAction)buttonSubmitPrefferencesPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *preferencesTableView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewPreferences;
- (IBAction)btnBackPressed:(id)sender;


@end
