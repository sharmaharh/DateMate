//
//  SelectTastesViewController.h
//  Dating
//
//  Created by Harsh Sharma on 12/2/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+ScrollIndicator.h"

@interface SelectTastesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewPreferences;
@property (strong, nonatomic) NSMutableArray *preferencesArray;
- (IBAction)btnProceedPressed:(id)sender;


@end
