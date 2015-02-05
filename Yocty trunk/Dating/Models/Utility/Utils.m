//  Utils.m
//  Dating
//
//  Created by Harsh Sharma on 7/29/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "Utils.h"
#import "ReachabilityNew.h"
#define kTitle @"Dating"

@implementation Utils


+ (id)sharedInstance
{
    static dispatch_once_t once=0;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark ----
#pragma mark - UIAlertView Methods

#pragma mark   1. With Delegates
+ (void) showAlertView :(NSString*)title message:(NSString*)msg delegate:(id)delegate
      cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate
										  cancelButtonTitle:CbtnTitle otherButtonTitles:otherBtnTitles, nil];
	[alert show];
}

+ (void) showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)msg delegate:(id)delegate
            cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate
										  cancelButtonTitle:CbtnTitle otherButtonTitles:otherBtnTitles, nil];
    alert.tag = tag;
	[alert show];
	
}

+ (void) showOKAlertWithTitle:(NSString*)aTitle message:(NSString*)aMsg
{
	UIAlertView	*aAlert = [[UIAlertView alloc] initWithTitle:aTitle message:aMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[aAlert show];
	
}

+ (void) showAlertViewWithTextFieldTag:(NSInteger)tag title:(NSString*)title message:(NSString*)msg delegate:(id)delegate
                     cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles
{
    
    //    if(![NULLVALUE(msg) length]>0)return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate
                                          cancelButtonTitle:CbtnTitle otherButtonTitles:otherBtnTitles, nil];
    alert.tag = tag;
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark   2. With Block

-(void)openAlertViewWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons completion:(void(^)(UIAlertView *alert,NSInteger buttonIndex))alertBlock
{
    self.alertCompletionBlock=alertBlock;
    //NSString *buttonTitles=[buttons componentsJoinedByString:@","];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    for(NSString *buttonTitle in buttons)
    {
        [alert addButtonWithTitle:buttonTitle];
    }
    [alert show];
}

-(void)openAlertViewUserNameWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons completion:(void(^)(UIAlertView *alert,NSInteger buttonIndex))alertBlock
{
    self.alertCompletionBlock=alertBlock;
    //NSString *buttonTitles=[buttons componentsJoinedByString:@","];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    for(NSString *buttonTitle in buttons)
    {
        [alert addButtonWithTitle:buttonTitle];
    }
    [alert show];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.alertCompletionBlock)
        self.alertCompletionBlock(alertView,buttonIndex);
    
}

#pragma mark UIActionSheet with Block

-(void)openActionSheetWithTitle:(NSString *)title buttons:(NSArray *)buttons completion:(void(^)(UIActionSheet *actionSheet,NSInteger buttonIndex))actionSheetBlock
{
    self.actionSheetCompletionBlock=actionSheetBlock;
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    //actionSheet.actionSheetStyle=UIActionSheetStyleDefault;
    for(NSString *buttonTitle in buttons)
    {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex=actionSheet.numberOfButtons-1;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // NSLog(@"second");
        
        if(self.actionSheetCompletionBlock)
            self.actionSheetCompletionBlock(actionSheet,buttonIndex);
        
    });
    
    // NSLog(@"first");
}


#pragma mark - Image Resize
+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(int) maxWidth maxHeight:(int) maxHeight
{
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    if (width <= maxWidth && height <= maxHeight)
	{
		return image;
	}
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
	
    if (width > maxWidth || height > maxHeight)
	{
		CGFloat ratio = width/height;
		
		if (ratio > 1)
		{
			bounds.size.width = maxWidth;
			bounds.size.height = bounds.size.width / ratio;
		}
		else
		{
			bounds.size.height = maxHeight;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
    CGFloat scaleRatio = bounds.size.width / width;
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);
    CGContextTranslateCTM(context, 0, -height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return imageCopy;
	
}

+ (UIImage *)scaleImage:(UIImage *)image WithRespectToFrame:(CGRect)imageRect
{
    CGImageRef imgRef = image.CGImage;
    CGFloat imgWidth = CGImageGetWidth(imgRef);
    CGFloat imgHeight = CGImageGetHeight(imgRef);
    
    CGFloat scaleFactor = 1;
    
    if (imgWidth >= imageRect.size.width && imgHeight < imageRect.size.height)
    {
        scaleFactor = imgHeight/imageRect.size.height;
    }
    else if (imgWidth < imageRect.size.width && imgHeight >= imageRect.size.height)
    {
        scaleFactor = imgWidth/imageRect.size.width;
    }
    else
    {
        if (imgWidth <= imgHeight)
        {
            scaleFactor = imgWidth/MAX(imageRect.size.width, imageRect.size.height);
//            if (imageRect.size.width >= imageRect.size.height)
//                scaleFactor = imageRect.size.width/imgWidth;
//            
//            else
//                scaleFactor = imageRect.size.height/imgHeight;
        }
        else
        {
            scaleFactor = imgHeight/MAX(imageRect.size.width, imageRect.size.height);
//            if (imageRect.size.width >= imageRect.size.height)
//                scaleFactor = imageRect.size.height/imgHeight;
//            
//            else
//                scaleFactor = imageRect.size.width/imgWidth;
        }
        
    }
    UIImage *imageCopy = [UIImage imageWithCGImage:imgRef scale:scaleFactor orientation:image.imageOrientation];
    
    
    return imageCopy;
    
}


#pragma mark Image Conversion
+ (NSString*) stringFromImage:(UIImage*)image
{
    //    NSData* imageData = UIImagePNGRepresentation(image);
    //
    //    //NSData *imageData = UIImageJPEGRepresentation(image, 1);
    //
    //    NSString *str = [imageData base64EncodingWithLineLength:80];
    //    return str;
    
    
    if(image){
		//NSData *dataObj = UIImagePNGRepresentation(image);
        NSData *dataObj = UIImageJPEGRepresentation(image,.75);
        
		return [dataObj base64Encoding];
	} else {
		return @"";
	}
}

#pragma mark - Use it when pickup an image from imagepicker
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image
{
	//int kMaxResolution = 320;
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	/*if (width > kMaxResolution || height > kMaxResolution)
	 {
	 CGFloat ratio = width/height;
	 if (ratio > 1)
	 {
	 bounds.size.width = kMaxResolution;
	 bounds.size.height = bounds.size.width / ratio;
	 }
	 else
	 {
	 bounds.size.height = kMaxResolution;
	 bounds.size.width = bounds.size.height * ratio;
	 }
	 } */
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient)
	{
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			break;
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
	{
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else
	{
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
	
}

+(BOOL)isInternetAvailable
{
    BOOL isInternetAvailable = false;
    ReachabilityNew *internetReach = [ReachabilityNew reachabilityForInternetConnection];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            isInternetAvailable = FALSE;
            break;
        case ReachableViaWWAN:
            isInternetAvailable = TRUE;
            break;
        case ReachableViaWiFi:
            isInternetAvailable = TRUE;
            break;
    }
    [internetReach stopNotifier];
    return isInternetAvailable;
}

#pragma mark-Check Email Formate

+(BOOL)emailValidate:(NSString *)email
{
	//Based on the string below
	//NSString *strEmailMatchstring=@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
	
	//Quick return if @ Or . not in the string
	if([email rangeOfString:@"@"].location==NSNotFound || [email rangeOfString:@"."].location==NSNotFound)
		//NSLog(@"%@",[email rangeOfString:@"@"]);
		//			NSLog(@"%@",[email rangeOfString:@"."]);
		return YES;
	
	//Break email address into its components
	NSString *accountName=[email substringToIndex: [email rangeOfString:@"@"].location];
	NSLog(@"%@",accountName);
	email=[email substringFromIndex:[email rangeOfString:@"@"].location+1];
	NSLog(@"%@",email);
	//'.' not present in substring
	if([email rangeOfString:@"."].location==NSNotFound)
		return YES;
	NSString *domainName=[email substringToIndex:[email rangeOfString:@"."].location];
	NSLog(@"%@",domainName);
	
	NSString *subDomain=[email substringFromIndex:[email rangeOfString:@"."].location+1];
	NSLog(@"%@",subDomain);
    
    
	
    if(!([subDomain rangeOfString:@"."].location==NSNotFound))
    {
        NSString *subSubDomain=[subDomain substringFromIndex:[subDomain rangeOfString:@"."].location+1];
        NSLog(@"%@",subSubDomain);
        if(!(subSubDomain.length>=2 && subSubDomain.length<=6))
            return YES;
    }
	//username, domainname and subdomain name should not contain the following charters below
	//filter for user name
	NSString *unWantedInUName = @" ~!@#$^&*()={}[]|;':\"<>,?/`";
	//filter for domain
	NSString *unWantedInDomain = @" ~!@#$%^&*()={}[]|;':\"<>,+?/`";
	//filter for subdomain
	NSString *unWantedInSub = @" `~!@#$%^&*()={}[]:\";'<>,?/1234567890";
	
	//subdomain should not be less that 2 and not greater 6
	if(!(subDomain.length>=2 && subDomain.length<=6))
		return YES;
	
	if([accountName isEqualToString:@""] || [accountName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInUName]].location!=NSNotFound || [domainName isEqualToString:@""] || [domainName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInDomain]].location!=NSNotFound || [subDomain isEqualToString:@""] || [subDomain rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:unWantedInSub]].location!=NSNotFound)
		return YES;
	
	return NO;
}


/*
 +(BOOL)emailValidate:(NSString *)email
 
 {
 //NSString *emailRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
 NSString *emailRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
 
 
 
 NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
 return [emailTest evaluateWithObject:email];
 
 }*/
#pragma mark -- Check device type
+ (BOOL) isiPad
{
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
    if ([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)])
        return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
#endif
    return NO;
}
#pragma mark:-color form hex
+ (UIColor *) colorWithHexString: (NSString *) hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

#pragma mark - dynamic height And width of Label

+  (CGSize) calculateLabelHeightWith:(CGFloat)width text:(NSString*)textString
{
    CGSize maximumSize = CGSizeMake(width, 9999);
    CGSize size = [textString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]
                         constrainedToSize:maximumSize
                             lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}

+ (CGSize) calculateLabelWidthOfString:(NSString*)textString withFont:(UIFont*)font
{
    CGSize maximumSize = CGSizeMake(9999, 22);
    CGSize size = [textString sizeWithFont:font
                         constrainedToSize:maximumSize
                             lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}

+ (void)fadeInAndFadeOutAnaimationWithView:(UIView*)aView
{
    
    if (aView.alpha == 0.0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration: 1.0];
        [UIView setAnimationDelegate: self];
        aView.alpha = 1.0;
        [UIView commitAnimations];
    }
    else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration: 1.0];
        [UIView setAnimationDelegate: self];
        aView.alpha = 0.0;
        [UIView commitAnimations];
    }
}

+ (NSDate*) dateFromString:(NSString*)aStr
{
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    //[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss a"];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss a"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
	NSLog(@"%@", aStr);
    NSDate   *aDate = [dateFormatter dateFromString:aStr];
	return aDate;
}

#pragma mark -  Get Lat Long
+(NSDictionary*) getLocationLatiLongiValueFromAddress:(NSString*)address
{
    NSError *err;
    NSString *latiValue = nil;
    NSString *longiValue = nil;
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",
                           [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&err];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
    
    
    double latitude = 0.0;
    double longitude = 0.0;
    
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"])
    {
        latitude = [[listItems objectAtIndex:2] doubleValue];
        longitude = [[listItems objectAtIndex:3] doubleValue];
    }
    else {
        //Show error
    }
    
    latiValue = [NSString stringWithFormat:@"%f",latitude];
    longiValue = [NSString stringWithFormat:@"%f",longitude];
    
    NSDictionary    *aDic = nil;
    aDic = [NSDictionary dictionaryWithObjectsAndKeys:latiValue,@"Latitude",longiValue,@"Longitude", nil];
    return aDic;
    
}


+(NSDate*)getCurrentSystemDate
{
    NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    return destinationDate;
}

+(NSString *)localDateForGmtDateString:(NSString *)messageDate
{
    NSDateFormatter *localFormatter = [[NSDateFormatter alloc] init];
    [localFormatter setDateStyle:NSDateFormatterShortStyle];
    [localFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSDateFormatter *gmtFormatter = [[NSDateFormatter alloc] init];
    [gmtFormatter setDateFormat:@"MM/dd/yyyy h:mm:ss a"];
    [gmtFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *date = [gmtFormatter dateFromString:messageDate];
    [localFormatter setDateFormat:@"MM/dd/yyyy h:mm:ss a"];
    
    messageDate = [localFormatter stringFromDate:date];
    
    return messageDate;
}

+(NSString *)localDateForGmtDate:(NSDate *)messageDate
{
    NSDateFormatter *localFormatter = [[NSDateFormatter alloc] init];
    [localFormatter setDateStyle:NSDateFormatterShortStyle];
    [localFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSDateFormatter *gmtFormatter = [[NSDateFormatter alloc] init];
    [gmtFormatter setDateFormat:@"MM/dd/yyyy h:mm:ss a"];
    //[gmtFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *dateStr = [gmtFormatter stringFromDate:messageDate];
    [localFormatter setDateFormat:@"MM/dd/yyyy h:mm:ss a"];
    
    
    
    return dateStr;
}

+(void)openActionSheetWithTag:(NSInteger)tag delegate:(id)delegate buttons:(NSArray *)buttons
{
    NSString *buttonTitles=[buttons componentsJoinedByString:@","];
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:kTitle delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:buttonTitles, nil];
    actionSheet.tag=tag;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

//#pragma mark Play Video
//
//+(void)playVideo:(NSString *)videoFile viewController:(UIViewController *)viewController
//{
//    //NSString *filepath   =   [[NSBundle mainBundle] pathForResource:videoFile ofType:@"mp4"];
//    //NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
//
//    NSURL    *fileURL    =   [NSURL URLWithString:videoFile];
//    UIGraphicsBeginImageContext(CGSizeMake(1,1));
//
//    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL ];
//
//    [[NSNotificationCenter defaultCenter] addObserver:[self class] selector:@selector(moviePlayBackComplete:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController.moviePlayer];
//
//    moviePlayerController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//    [viewController presentMoviePlayerViewControllerAnimated:moviePlayerController];
//    [moviePlayerController.moviePlayer play];
//
//
//}
//
//
//+ (void)moviePlayBackComplete:(NSNotification *)notification
//{
//    NSLog(@"moviePlaybackComplete");
//    MPMoviePlayerViewController* moviePlayerController = [notification object];
//    //[moviePlayerController. dismissMoviePlayerViewControllerAnimated];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController];
//}

#pragma mark Animate TextField
+(void)animateUpTextField:(UITextField *)textField inView:(UIView *)view
{
    [UIView animateWithDuration:0.2 animations:^{
        if (textField.frame.origin.y>(view.frame.size.height/2-20)) {
            [view setTransform:CGAffineTransformMakeTranslation(0, -130)];
        }
        
    } completion:nil];
}
+(void)animateDownTextField:(UITextField *)textField inView:(UIView *)view
{
    [UIView animateWithDuration:0.2 animations:^{
        [view setTransform:CGAffineTransformMakeTranslation(0, 0)];
    } completion:nil];
    
}

#pragma mark Open Camera/Photo
+(void)openImagePickerController:(UIImagePickerControllerSourceType)sourceType delegate:(id)delegate
{
    UIImagePickerController *controller=[[UIImagePickerController alloc] init];
    controller.delegate=delegate;
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        controller.sourceType=sourceType;
        [delegate presentViewController:controller animated:YES completion:nil];
        
    }
    else
    {
        [Utils showOKAlertWithTitle:kTitle message:@"Not support on this device"];
    }
    
}

+(UIImage *)generateThumbNailOfVideo:(NSURL *)videoUrl
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return thumbImage;
}
+(void)addPickerWithToolBarFrame:(UIView *)picker toolBar:(UIToolbar *)doneToolBar inView:(UIView *)view
{
    CGRect frame;
    frame.origin=view.center;
    frame.origin.x=0;
    frame.origin.y=view.frame.size.height-picker.frame.size.height;
    frame.size=picker.frame.size;
    picker.frame=frame;
    
    frame.origin.y-=doneToolBar.frame.size.height;
    frame.size=doneToolBar.frame.size;
    doneToolBar.frame=frame;
    
    [view addSubview:picker];
    [view addSubview:doneToolBar];
}

+ (void)configureLayerForHexagonWithView:(UIView *)view withBorderColor:(UIColor *)color WithCornerRadius:(CGFloat)cornerRadius WithLineWidth:(CGFloat)lineWidth withPathColor:(UIColor *)pathStrokeColor
{
    UIBezierPath *path   = [Utils roundedPolygonPathWithRect:view.bounds
                                                  lineWidth:lineWidth
                                                      sides:6
                                               cornerRadius:cornerRadius];
    
    CAShapeLayer *mask   = [CAShapeLayer layer];
    mask.path            = path.CGPath;
    mask.lineWidth       = lineWidth;
    mask.strokeColor     = pathStrokeColor.CGColor;
    mask.fillColor       = [UIColor whiteColor].CGColor;
    view.layer.mask = mask;
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.path          = path.CGPath;
    border.lineWidth     = lineWidth;
    border.strokeColor   = color.CGColor;
    border.fillColor     = [UIColor clearColor].CGColor;
    
    [view.layer addSublayer:border];
    
}

+ (UIBezierPath *)roundedPolygonPathWithRect:(CGRect)square
                                   lineWidth:(CGFloat)lineWidth
                                       sides:(NSInteger)sides
                                cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *path  = [UIBezierPath bezierPath];
    
    CGFloat theta       = 2.0 * M_PI / sides;                           // how much to turn at every corner
    CGFloat offset      = cornerRadius * tanf(theta / 2.0);             // offset from which to start rounding corners
    CGFloat squareWidth = MIN(square.size.width, square.size.height);   // width of the square
    
    // calculate the length of the sides of the polygon
    
    CGFloat length      = squareWidth - lineWidth;
    if (sides % 4 != 0) {                                               // if not dealing with polygon which will be square with all sides ...
        length = length * cosf(theta / 2.0) + offset/2.0;               // ... offset it inside a circle inside the square
    }
    CGFloat sideLength = length * tanf(theta / 2.0);
    
    // start drawing at `point` in lower right corner
    
    CGPoint point = CGPointMake(squareWidth / 2.0 - offset, squareWidth - (squareWidth - length) / 2.0);
    CGFloat angle = M_PI*1.165000;
    [path moveToPoint:point];
    
    // draw the sides and rounded corners of the polygon
    
    for (NSInteger side = 0; side < sides; side++) {
        point = CGPointMake(point.x + (sideLength - offset * 2.0) * cosf(angle), point.y + (sideLength - offset * 2.0) * sinf(angle));
        [path addLineToPoint:point];
        
        CGPoint center = CGPointMake(point.x + cornerRadius * cosf(angle + M_PI_2), point.y + cornerRadius * sinf(angle + M_PI_2));
        [path addArcWithCenter:center radius:cornerRadius startAngle:angle - M_PI_2 endAngle:angle + theta - M_PI_2 clockwise:YES];
        
        point = path.currentPoint; // we don't have to calculate where the arc ended ... UIBezierPath did that for us
        angle += theta;
    }
    
    [path closePath];
    
    return path;
}

#pragma mark Tracking & Updating Location

- (void)startLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if(![CLLocationManager locationServicesEnabled])
    {
        [Utils showOKAlertWithTitle:@"Location Services Disabled" message:@"Yocty requires your location. Please allow access from settings."];
    }
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations firstObject];
}

- (void)startHSLoaderInView:(UIView *)view
{
    if (!self.hsProgressIndicator)
    {
        self.hsProgressIndicator = [[HSProgressIndicator alloc] initWithFrame:view.bounds];
        [self.hsProgressIndicator customizeView];
    }
    
    if (!self.hsProgressIndicator.isAnimating)
    {
        [self.hsProgressIndicator startLoading];
        [view addSubview:self.hsProgressIndicator];
    }
    
}

- (void)stopHSLoader
{
    [self.hsProgressIndicator stopLoading];
    [self.hsProgressIndicator removeFromSuperview];
}

@end
