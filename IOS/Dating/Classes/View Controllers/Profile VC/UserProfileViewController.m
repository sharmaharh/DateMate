//
//  UserProfileViewController.m
//  Dating
//
//  Created by Harsh Sharma on 9/28/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileViewController ()
{
    UIImagePickerController *imagePickerController;
    NSInteger selectedButtonTag;
    NSInteger currentPannedButtonTag;
    NSMutableArray *editedArray;
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
        self.imagesArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"ProfileImages"];
    }
    editedArray = [NSMutableArray arrayWithObjects:@"",@"",@"",@"", nil];
    [self setImagesOnLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImagesOnLayout
{
    for (int i = 0; i < 4; i++)
    {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i+1];
        
        UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        [btn addGestureRecognizer:longTapGesture];
        
        [btn addTarget:self action:@selector(profilePictureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[self.view viewWithTag:i+11];
        if (self.imagesArray.count > i)
        {
            if ([self.imagesArray[i] isKindOfClass:[UIImage class]])
            {
                [btn setImage:self.imagesArray[i] forState:UIControlStateNormal];
                [activityIndicatorView stopAnimating];
            }
            else
            {
                [self setImageOnButton:btn WithURL:self.imagesArray[i] WithProgressIndicator:activityIndicatorView];
            }            
        }
    }
}

- (void)handleLongTap:(UILongPressGestureRecognizer *)recognizer
{
    
    UIButton *Btn = (UIButton *)recognizer.view;
    
    // Create Temp Button on View
    UIButton *tempButton = [[UIButton alloc] initWithFrame:recognizer.view.frame];
    [tempButton setImage:Btn.currentImage forState:UIControlStateNormal];
    
    tempButton.tag = Btn.tag;
    Btn.tag = tempButton.tag*2;
    
    [self.view insertSubview:tempButton belowSubview:Btn];
    [tempButton.layer setBorderColor:[UIColor redColor].CGColor];
    [tempButton.layer setBorderWidth:1.0];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches=1;
    panGesture.minimumNumberOfTouches=1;
    
    [Btn addGestureRecognizer:panGesture];
    
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
    UIButton *button1 = (UIButton *)[self.view viewWithTag:1];
    UIButton *button2 = (UIButton *)[self.view viewWithTag:2];
    UIButton *button3 = (UIButton *)[self.view viewWithTag:3];
    UIButton *button4 = (UIButton *)[self.view viewWithTag:4];
    
    BOOL isIntersect1 = CGRectIntersectsRect(recognizer.view.frame, button1.frame);
    BOOL isIntersect2 = CGRectIntersectsRect(recognizer.view.frame, button2.frame);
    BOOL isIntersect3 = CGRectIntersectsRect(recognizer.view.frame, button3.frame);
    BOOL isIntersect4 = CGRectIntersectsRect(recognizer.view.frame, button4.frame);
    
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
        if (isIntersect1)
        {
            [button1.layer setBorderColor:[UIColor redColor].CGColor];
            [button1.layer setBorderWidth:1.0f];
            [button2.layer setBorderWidth:0.0f];
            [button3.layer setBorderWidth:0.0f];
            [button4.layer setBorderWidth:0.0f];
        }
        
        else if (isIntersect2)
        {
            [button2.layer setBorderColor:[UIColor redColor].CGColor];
            [button2.layer setBorderWidth:1.0f];
            [button1.layer setBorderWidth:0.0f];
            [button3.layer setBorderWidth:0.0f];
            [button4.layer setBorderWidth:0.0f];
        }
        
        
        else if (isIntersect3)
        {
            [button3.layer setBorderColor:[UIColor redColor].CGColor];
            [button3.layer setBorderWidth:1.0f];
            [button1.layer setBorderWidth:0.0f];
            [button2.layer setBorderWidth:0.0f];
            [button4.layer setBorderWidth:0.0f];
        }
        else if (isIntersect4)
        {
            [button4.layer setBorderColor:[UIColor redColor].CGColor];
            [button4.layer setBorderWidth:1.0f];
            [button1.layer setBorderWidth:0.0f];
            [button2.layer setBorderWidth:0.0f];
            [button3.layer setBorderWidth:0.0f];
        }
    }

    UIButton *tempbutton = (UIButton *)recognizer.view;
    
    if([recognizer state] == UIGestureRecognizerStateEnded)
    {
        UIImage *intersectedButtonImage = nil;
        
        if (isIntersect1)
            intersectedButtonImage = button1.currentImage;
        
        else if (isIntersect2)
            intersectedButtonImage = button2.currentImage;
        
        else if (isIntersect3)
            intersectedButtonImage = button3.currentImage;
        
        else if (isIntersect4)
            intersectedButtonImage = button4.currentImage;
        
        
        UIImage *tempbuttonImage = tempbutton.currentImage;
        
        [button1 setImage:tempbuttonImage forState:UIControlStateNormal];
        
        UIButton *pannedButton = (UIButton *)[self.view viewWithTag:tempbutton.tag/2];
        [tempbutton removeFromSuperview];
        [pannedButton setImage:intersectedButtonImage forState:UIControlStateNormal];
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (NSString *)ProfileImageFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Profile_Images"];
    basePath = [basePath stringByAppendingPathComponent:self.fbId];
    return basePath;
}

- (void)setImageOnButton:(UIButton *)btn WithURL:(NSString *)imageURL WithProgressIndicator:(UIActivityIndicatorView *)activityIndicator
{
    if (!imageURL || !imageURL.length) {
        return;
    }
    __block NSString *bigImageURLString = imageURL;
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    
    NSString *dirPath = [self ProfileImageFolderPath];
    NSString *filePath = [dirPath stringByAppendingPathComponent:[imageURL lastPathComponent]];
    
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        [btn setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]] forState:UIControlStateNormal];
        [activityIndicator stopAnimating];
    }
    else
    {
        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
            
            
            __block NSData *imageData = nil;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                
                imageData = data;
                UIImage *image = nil;
                data = nil;
                image = [UIImage imageWithData:imageData];
                if (image == nil)
                {
                    image = [UIImage imageNamed:@"Bubble-0"];
                }
                
                [btn setImage:image forState:UIControlStateNormal];
                [activityIndicator stopAnimating];
                
                // Write Image in Document Directory
                int64_t delayInSeconds = 0.4;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                
                dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
                    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                    {
                        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
                        {
                            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        
                        [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
                        imageData = nil;
                    }
                });
                
            }];
            
            bigImageURLString = nil;
            
            
        });
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (IBAction)btnRevealPressed:(id)sender
{
    [self.revealViewController revealToggle:self];
}

- (IBAction)btnSaveProfilePressed:(id)sender
{
//    NSDictionary *reqDict = @{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, };
//    AFNHelper *afnHelper = [AFNHelper new];
//    [afnHelper getDataFromPath:<#(NSString *)#> withParamDataImage:<#(NSMutableDictionary *)#> andImage:<#(UIImage *)#> withBlock:<#^(id response, NSError *error)block#>]
}

#pragma mark ----
#pragma mark UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:selectedButtonTag];
    [btn setImage:info[UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
    if (info[UIImagePickerControllerEditedImage])
    {
        [editedArray replaceObjectAtIndex:selectedButtonTag-1 withObject:info[UIImagePickerControllerEditedImage]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
