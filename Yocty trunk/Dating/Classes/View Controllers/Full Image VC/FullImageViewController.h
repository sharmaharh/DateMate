//
//  FullImageViewController.h
//  Dating
//
//  Created by Harsh Sharma on 9/29/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullImageViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewImages;
@property (strong, nonatomic) NSArray *arrPhotoGallery;
@property (assign, nonatomic) NSInteger currentPhotoIndex;
@property (strong, nonatomic) NSString *fbID;

@end
