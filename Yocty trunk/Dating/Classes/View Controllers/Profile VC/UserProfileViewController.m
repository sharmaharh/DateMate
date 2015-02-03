//
//  UserProfileViewController.m
//  Dating
//
//  Created by Harsh Sharma on 9/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "UserProfileViewController.h"
#import "RearMenuViewController.h"

@interface UserProfileViewController ()
{
    UIImagePickerController *imagePickerController;
    NSInteger selectedButtonTag;
    NSInteger currentPannedButtonTag;
    NSMutableArray *editedArray;
    NSMutableArray *deletedImageUrlArray;
    BOOL shouldStartPanning;
    id ProfileImage;
}
@end

@implementation UserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![self.imagesArray count])
    {
        self.imagesArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ProfileImages"] mutableCopy];
    }
    editedArray = [NSMutableArray arrayWithObjects:@"",@"",@"", nil];
    deletedImageUrlArray = [NSMutableArray array];
    [self setImagesOnLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    editedArray = nil;
    ProfileImage = nil;
    imagePickerController = nil;
}

- (void)setImagesOnLayout
{
    for (int i = 0; i < 4; i++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i+1];
        [btn.layer setCornerRadius:btn.frame.size.height/2];
        [btn setClipsToBounds:YES];
        [btn.layer setBorderColor:[UIColor whiteColor].CGColor];
        [btn.layer setBorderWidth:1.0f];
        if (i)
        {
            // Add Long Tap Gesture
            
            UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
            longTapGesture.delegate = self;
            [btn addGestureRecognizer:longTapGesture];
            
            // Add Pan Gesture
            
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            panGesture.delegate = self;
            panGesture.maximumNumberOfTouches=1;
            panGesture.minimumNumberOfTouches=1;
            
            [btn addGestureRecognizer:panGesture];
        }
        
        [btn addTarget:self action:@selector(profilePictureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[self.view viewWithTag:i+11];
        if (self.imagesArray.count > i)
        {
            [self setImageOnButton:btn WithURL:self.imagesArray[i] WithProgressIndicator:activityIndicatorView];
        }
    }
}

- (void)handleLongTap:(UILongPressGestureRecognizer *)recognizer
{
    if([recognizer state] == UIGestureRecognizerStateBegan)
    {
        UIButton *Btn = (UIButton *)recognizer.view;
        NSInteger btnTag = Btn.tag;
        [self.view bringSubviewToFront:Btn];
        // Create Replacement Temp Button on View
        
        UIButton *tempButton = [[UIButton alloc] initWithFrame:recognizer.view.frame];
        [tempButton setImage:Btn.currentImage forState:UIControlStateNormal];
        [tempButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [tempButton setClipsToBounds:YES];
        [tempButton.layer setCornerRadius:tempButton.frame.size.height/2];
        [tempButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [tempButton.layer setBorderWidth:1.0f];
        UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        [tempButton addTarget:self action:@selector(profilePictureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [tempButton setBackgroundColor:[UIColor grayColor]];
        longTapGesture.delegate = self;
        [tempButton addGestureRecognizer:longTapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panGesture.delegate = self;
        panGesture.maximumNumberOfTouches=1;
        panGesture.minimumNumberOfTouches=1;
        
        [tempButton addGestureRecognizer:panGesture];
        tempButton.tag = btnTag;
        
        Btn.tag = btnTag*2;
        
        [self.view insertSubview:tempButton belowSubview:Btn];
        [Btn.layer setBorderColor:[UIColor redColor].CGColor];
        [Btn.layer setBorderWidth:1.0];
        [self popUpDeleteView];
    }
    else if([recognizer state] == UIGestureRecognizerStateEnded)
    {
        [self dismissDeleteView];
    }
}

- (void)popUpDeleteView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewDelete setFrame:CGRectMake(0, self.view.frame.size.height-self.viewDelete.frame.size.height, self.view.frame.size.height, self.viewDelete.frame.size.height)];
        
    }];
}

- (void)dismissDeleteView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewDelete setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.height, self.viewDelete.frame.size.height)];
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
    
    UIButton *button1 = (UIButton *)[self.view viewWithTag:1];
    
    BOOL isIntersectWithImage = CGRectIntersectsRect(recognizer.view.frame, button1.frame);
    BOOL isIntersectWithDeletion = CGRectIntersectsRect(recognizer.view.frame, self.viewDelete.frame);
    
    if([recognizer state] == UIGestureRecognizerStateBegan)
    {
        currentPannedButtonTag = recognizer.view.tag/2;
        
        if(currentPannedButtonTag==1)
        {
            
        }
        else if(currentPannedButtonTag==2)
        {
            
        }
        else if(currentPannedButtonTag==3)
        {
            
        }
        else
        {
            
        }
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        [self.viewDelete.layer setBorderWidth:0.0f];
        [button1.layer setBorderColor:[UIColor whiteColor].CGColor];
        if (isIntersectWithImage)
        {
            [button1.layer setBorderColor:[UIColor redColor].CGColor];
        }
        
        if (isIntersectWithDeletion)
        {
            [self.viewDelete.layer setBorderWidth:1.0f];
            [self.viewDelete.layer setBorderColor:[UIColor yellowColor].CGColor];
        }
    }

    UIButton *tempbutton = (UIButton *)recognizer.view;
    
    if([recognizer state] == UIGestureRecognizerStateEnded)
    {
        shouldStartPanning = NO;
        UIImage *intersectedButtonImage = nil;
        
        UIButton *pannedButton = (UIButton *)[self.view viewWithTag:tempbutton.tag/2];
        
        if(isIntersectWithImage)
        {
            intersectedButtonImage = button1.currentImage;
                    
            UIImage *tempbuttonImage = tempbutton.currentImage;
            
            [button1 setImage:[Utils scaleImage:tempbuttonImage WithRespectToFrame:button1.frame] forState:UIControlStateNormal];
            [button1.layer setBorderColor:[UIColor whiteColor].CGColor];
            [pannedButton setImage:[Utils scaleImage:intersectedButtonImage WithRespectToFrame:pannedButton.frame] forState:UIControlStateNormal];
            
            [self.imagesArray exchangeObjectAtIndex:pannedButton.tag-1 withObjectAtIndex:0];
        }
        
        if (isIntersectWithDeletion)
        {
            [pannedButton setImage:nil forState:UIControlStateNormal];
            [self.imagesArray replaceObjectAtIndex:pannedButton.tag-1 withObject:@""];
        }
        
        [tempbutton removeFromSuperview];
        [self dismissDeleteView];
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"Gesture Class = %@",NSStringFromClass([gestureRecognizer class]));
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        shouldStartPanning = YES;
        return YES;
    }
    
    if (shouldStartPanning)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)setImageOnButton:(UIButton *)btn WithURL:(NSString *)imageURL WithProgressIndicator:(UIActivityIndicatorView *)activityIndicator
{
    [btn.imageView setContentMode:UIViewContentModeCenter];
    [activityIndicator startAnimating];
    
    [[HSImageDownloader sharedInstance] imageWithImageURL:imageURL withFBID:self.fbId withImageDownloadedBlock:^(UIImage *image, NSString *imgURL, NSError *error) {
        [activityIndicator stopAnimating];
        
        if (!error)
        {
            [btn setImage:[Utils scaleImage:image WithRespectToFrame:btn.frame] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"Bubble-0"] forState:UIControlStateNormal];
        }
    }];

}

- (void)profilePictureBtnPressed:(UIButton *)btn
{
    // Open Action Sheet
    selectedButtonTag = btn.tag;
    if (!imagePickerController)
    {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        
    }
    
    [[Utils sharedInstance] openActionSheetWithTitle:@"Take Photo" buttons:@[@"Camera",@"Gallery"] completion:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        if (buttonIndex == 1)
        {
            // Gallery
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        else if(buttonIndex == 0)
        {
            // Camera
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
            {
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            else
            {
                imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        
    }];
}

- (IBAction)btnSaveProfilePressed:(id)sender
{
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {
        [[Utils sharedInstance] startHSLoaderInView:self.view];
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:[FacebookUtility sharedObject].fbID forKey:@"ent_user_fbid"];
        
        if (ProfileImage)
        {
            [requestDict setObject:ProfileImage forKey:@"ent_prof_file"];
        }
        NSArray *localEditedArray = [editedArray copy];
        if ([editedArray count])
        {
            [editedArray removeObjectIdenticalTo:@""];
        }
        
        [requestDict setObject:editedArray forKey:@"ent_img_file"];
        [requestDict setObject:@"2" forKey:@"ent_image_flag"];
        [requestDict setObject:[deletedImageUrlArray count]?@"1":@"0" forKey:@"ent_delete_flag"];
        [requestDict setObject:[[deletedImageUrlArray componentsJoinedByString:@","] length]?[deletedImageUrlArray componentsJoinedByString:@","]:@"" forKey:@"ent_image_name"];
        
        AFNHelper *afnHelper = [AFNHelper new];
        [afnHelper getDataWithMultipartRequestFromPath:@"uploadImage" withParamDataImage:requestDict withBlock:^(id response, NSError *error) {
            [[Utils sharedInstance] stopHSLoader];
            if(!error)
            {
                /*
                 response: {
                 errFlag = 0;
                 errMsg = "Image upload completed successfully.";
                 errNum = 18;
                 images =     (
                 {
                 flag = 1;
                 url = "http://69.195.70.43/playground/ws/pics/1422984760myImage0.png";
                 },
                 {
                 flag = 1;
                 url = "http://69.195.70.43/playground/ws/pics/1422984760myImage1.png";
                 }
                 );
                 picURL = "http://69.195.70.43/playground/ws/pics/1422984760profileImage.png";
                 profFlag = 1;
                 }*/
                
                if (ProfileImage)
                {
                    RearMenuViewController *rearMenuViewController = (RearMenuViewController *)appDelegate.revealController.leftMenuViewController;
                    rearMenuViewController.proflePicImageView.image = [Utils scaleImage:ProfileImage WithRespectToFrame:rearMenuViewController.proflePicImageView.frame];
                    NSMutableArray *reqImageArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"ProfileImages"] mutableCopy];
                    if (response[@"picURL"])
                    {
                        [reqImageArray replaceObjectAtIndex:0 withObject:response[@"picURL"]];
                    }
                    if ([response[@"images"] count])
                    {
                        for (int i = 0 ; i < [response[@"images"] count]; i++)
                        {
                            if (![localEditedArray[i] isKindOfClass:[NSString class]])
                            {
                                [reqImageArray replaceObjectAtIndex:i+1 withObject:response[@"images"][i][@"url"]];
                            }
                        }
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:reqImageArray forKey:@"ProfileImages"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
        }];
    }

}

#pragma mark ----
#pragma mark UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:selectedButtonTag];
    
    UIImage *editedImage = [UIImage imageWithData:UIImageJPEGRepresentation(info[UIImagePickerControllerEditedImage], 0.3)];
    if (selectedButtonTag == 1)
    {
        ProfileImage = editedImage;
    }
    else
    {
        if (![deletedImageUrlArray containsObject:self.imagesArray[selectedButtonTag-1]])
        {
            [deletedImageUrlArray addObject:self.imagesArray[selectedButtonTag-1]];
        }
        
        if (info[UIImagePickerControllerEditedImage])
        {
            [editedArray replaceObjectAtIndex:selectedButtonTag-2 withObject:editedImage];
        }
    }
    [btn setImage:[Utils scaleImage:editedImage WithRespectToFrame:btn.frame] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
