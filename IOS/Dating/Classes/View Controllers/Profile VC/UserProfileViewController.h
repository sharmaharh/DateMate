//
//  UserProfileViewController.h
//  Dating
//
//  Created by Harsh Sharma on 9/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) IBOutlet UIView *viewDelete;

- (IBAction)btnSaveProfilePressed:(id)sender;
@end
