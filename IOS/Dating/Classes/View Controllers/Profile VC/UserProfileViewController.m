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
    
}

#pragma mark ----
#pragma mark UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:selectedButtonTag];
    [btn setImage:info[UIImagePickerControllerEditedImage] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
