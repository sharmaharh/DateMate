//
//  FullImageViewController.m
//  Dating
//
//  Created by Harsh Sharma on 9/29/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "FullImageViewController.h"
#define ZOOM_STEP 3.0
#define ProfileImagesAlbum "ProfileImages"

@interface FullImageViewController ()

@end

@implementation FullImageViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --UIcollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrPhotoGallery.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // if (collectionView == self.collViewDetail) {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    UIScrollView *scrollView = (UIScrollView *)[cell.contentView viewWithTag:1];
    scrollView.contentSize = CGSizeZero;
    scrollView.zoomScale = 1.0;
    [scrollView setFrame:(CGRect){0,0,cell.frame.size.width,cell.frame.size.height}];
    [scrollView setBackgroundColor:[UIColor greenColor]];
    scrollView.delegate = self;
    
    UIImageView *imageView = (UIImageView *)[scrollView viewWithTag:2];
    [imageView setFrame:(CGRect){0,0,scrollView.frame.size.width,scrollView.frame.size.height}];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageView.image = nil;
    
    
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:3];
    
    if (!activityIndicator.isAnimating)
    {
        [activityIndicator startAnimating];
    }
    
    NSString *bigImageURLString = [self.arrPhotoGallery[indexPath.row] objectForKey:@"pImg"];
    
    
    [self setImageOnImageView:imageView WithActivityIndicator:activityIndicator WithImageURL:bigImageURLString];
    
    UILabel *photoIndexLabel = (UILabel *)[cell.contentView viewWithTag:4];
    [photoIndexLabel setText:[NSString stringWithFormat:@"%i of %i",indexPath.row+1,self.arrPhotoGallery.count]];
    
    
    return cell;
}

- (void)setImageOnImageView:(UIImageView *)imageView WithActivityIndicator:(UIActivityIndicatorView *)activityIndicator WithImageURL:(NSString *)ImageURL
{
    if (!ImageURL || !ImageURL.length) {
        return;
    }
    __block NSString *bigImageURLString = ImageURL;
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    
    NSString *dirPath = nil;
    
    if ([self.fbID length])
    {
        dirPath = [self ProfileImageFolderPathWithFBID:self.fbID];
    }
    else
    {
        dirPath = [self AttachmentsFolderPath];
    }
    
    NSString *filePath = [dirPath stringByAppendingPathComponent:[ImageURL lastPathComponent]];
    
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        if (image)
        {
            [imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]]];
            [self adjustPhotoIndexLabelAccordingtoImageView:imageView];
            [activityIndicator stopAnimating];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [self setImageOnImageView:imageView WithActivityIndicator:activityIndicator WithImageURL:ImageURL];
        }
        
    }
    else
    {
        dispatch_async(dispatch_queue_create("ProfilePics", nil), ^{
            
            
            __block NSData *imageData = nil;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error)
            {
                if (!error)
                {
                    imageData = data;
                    UIImage *image = nil;
                    data = nil;
                    image = [UIImage imageWithData:imageData];
                    if (image == nil)
                    {
                        image = [UIImage imageNamed:@"Bubble-0"];
                    }
                    
                    [imageView setImage:image];
                    [self adjustPhotoIndexLabelAccordingtoImageView:imageView];
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
                }
            }];
            
            bigImageURLString = nil;
            
            
        });
    }
    
}

- (void)setLazyLoadingWith:(NSString*)imgURLString FilePath:(NSString*)filePath ImageView:(UIImageView*)newsThumbnailimageView CollectionView:(UICollectionView *)collectionView IndexPath:(NSIndexPath*)indexPath withActivityLoader:(UIActivityIndicatorView *)activityIndicator
{
    if (!imgURLString || !imgURLString.length) {
        return;
    }
    __block NSString *bigImageURLString = imgURLString;
    //    BOOL doesExist = [arrFilePath containsObject:filePath];
    BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (doesExist)
    {
        newsThumbnailimageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
        [self adjustPhotoIndexLabelAccordingtoImageView:newsThumbnailimageView];
        
        [activityIndicator stopAnimating];
    }
    else
    {
        dispatch_async(dispatch_queue_create("News", nil), ^{
            
            
            __block NSData *imageData = nil;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bigImageURLString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                UICollectionViewCell *cellToUpdate = [collectionView cellForItemAtIndexPath:indexPath]; // create a copy of the cell to avoid keeping a strong pointer to "cell" since that one may have been reused by the time the block is ready to update it.
                imageData = data;
                UIImage *image = nil;
                data = nil;
                image = [UIImage imageWithData:imageData];
                if (image == nil)
                {
                    image = [UIImage imageNamed:@"Bubble-0"];
                }
                if (cellToUpdate != nil){
                    /*
                     UIImageView *newNewsThumbnailimageView = (UIImageView *)[cellToUpdate.contentView viewWithTag:1];
                     [newNewsThumbnailimageView setImage:image];
                     */
                    [newsThumbnailimageView setImage:image];
                    [self adjustPhotoIndexLabelAccordingtoImageView:newsThumbnailimageView];
                    [activityIndicator stopAnimating];
                    [cellToUpdate setNeedsLayout];
                }
                
                // Write Image in Document Directory
                int64_t delayInSeconds = 0.4;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                
                dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
                    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                    {
//                        if (![[NSFileManager defaultManager] fileExistsAtPath:Category_NewsDetailsFullSizePhotos_FilePath([Shared shared].currentCategoryURLString,self.storyID)])
//                        {
//                            [[NSFileManager defaultManager] createDirectoryAtPath:Category_NewsDetailsFullSizePhotos_FilePath([Shared shared].currentCategoryURLString,self.storyID) withIntermediateDirectories:YES attributes:nil error:nil];
//                        }
//                        //                            [self AddFilePath:indexPath.row];
//                        [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
                        imageData = nil;
                    }
                });
                
            }];
            
            bigImageURLString = nil;
            
            
        });
    }
}

- (NSString *)ProfileImageFolderPathWithFBID:(NSString *)fbID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Profile_Images"];
    basePath = [basePath stringByAppendingPathComponent:fbID];
    return basePath;
}

- (NSString *)AttachmentsFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = [paths objectAtIndex:0];
    
    basePath = [basePath stringByAppendingPathComponent:@"Attachments"];
    basePath = [basePath stringByAppendingPathComponent:[FacebookUtility sharedObject].fbID];
    return basePath;
}

- (void)adjustPhotoIndexLabelAccordingtoImageView:(UIImageView *)imageView
{
    CGSize aspectedSize = [self imageSizeAfterAspectFit:imageView];
    
    CGFloat yAxis = (imageView.frame.size.height-aspectedSize.height)/2;
    CGFloat xAxis = (imageView.frame.size.width-aspectedSize.width)/2;
    
    [imageView setFrame:CGRectMake(xAxis, yAxis, aspectedSize.width, aspectedSize.height)];
    
    //    UILabel *newsIndexLabel = (UILabel *)[[scrollView superview] viewWithTag:2];
    //    newsIndexLabel.frame = CGRectMake(newsIndexLabel.frame.origin.x, yAxis, newsIndexLabel.frame.size.width, newsIndexLabel.frame.size.height);
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    //Adding gesture recognizer
    [imageView addGestureRecognizer:doubleTap];
    [imageView addGestureRecognizer:singleTap];
}

-(CGSize)imageSizeAfterAspectFit:(UIImageView*)imgview
{
    float newwidth = 0;
    float newheight = 0;
    
    UIImage *image=imgview.image;
    if (image)
    {
        if (image.size.height>=image.size.width){
            newheight=imgview.frame.size.height;
            newwidth=(image.size.width/image.size.height)*newheight;
            
            if(newwidth>imgview.frame.size.width){
                float diff=imgview.frame.size.width-newwidth;
                newheight=newheight+diff/newheight*newheight;
                newwidth=imgview.frame.size.width;
            }
            
        }
        else{
            newwidth=imgview.frame.size.width;
            newheight=(image.size.height/image.size.width)*newwidth;
            
            if(newheight>imgview.frame.size.height){
                float diff=imgview.frame.size.height-newheight;
                newwidth=newwidth+diff/newwidth*newwidth;
                newheight=imgview.frame.size.height;
            }
        }
    }
    NSLog(@"image after aspect fit: width=%f height=%f",newwidth,newheight);
    
    
    //adapt UIImageView size to image size
    //imgview.frame=CGRectMake(imgview.frame.origin.x+(imgview.frame.size.width-newwidth)/2,imgview.frame.origin.y+(imgview.frame.size.height-newheight)/2,newwidth,newheight);
    
    return CGSizeMake(newwidth, newheight);
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.collectionViewImages scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPhotoIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
}

#pragma mark UIImageView Scaling

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:2];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // zoom in
    UIScrollView *scrollView = (UIScrollView *)[gestureRecognizer.view superview];
    float newScale = [scrollView zoomScale] * ZOOM_STEP;
    
    if (newScale > scrollView.maximumZoomScale)
    {
        newScale = scrollView.minimumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view] onScrollView:scrollView];
        
        [scrollView zoomToRect:zoomRect animated:YES];
        
    }
    else{
        
        newScale = scrollView.maximumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view] onScrollView:scrollView];
        
        [scrollView zoomToRect:zoomRect animated:YES];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center onScrollView:(UIScrollView *)scrollView
{
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
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

@end
