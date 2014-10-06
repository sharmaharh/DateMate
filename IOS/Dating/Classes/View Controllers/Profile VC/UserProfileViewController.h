//
//  UserProfileViewController.h
//  Dating
//
//  Created by Harsh Sharma on 9/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) NSArray *imagesArray;
@property (strong, nonatomic) NSString *fbId;

- (IBAction)btnRevealPressed:(id)sender;

- (IBAction)btnSaveProfilePressed:(id)sender;
@end
