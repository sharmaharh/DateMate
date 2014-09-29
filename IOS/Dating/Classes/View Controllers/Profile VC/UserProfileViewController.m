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

- (void)setImageOnButton:(UIButton *)btn WithURL:(NSString *)imageURL WithProgressIndicator:(UIActivityIndicatorView *)activityIndicator
{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [activityIndicator startAnimating];
    [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         [activityIndicator stopAnimating];
         if (!connectionError)
         {
             UIImage *image = [UIImage imageWithData:data];
             if (image)
             {
                 [btn setImage:image forState:UIControlStateNormal];
                 
             }
         }
         
     }];
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
