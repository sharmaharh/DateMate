//
//  Utils.h
//  Dating
//
//  Created by Harsh Sharma on 7/29/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject <UIActionSheetDelegate>


/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Void
 Functionality : To Create a Singelton Object of Utils, which will be alive throughout the run of the app.
 
 ------------------------------------------------------*/

+ (Utils *)sharedInstance;

@property(assign,nonatomic)BOOL internetActive;
@property(nonatomic,copy) void(^alertCompletionBlock)(UIAlertView *alert ,NSInteger index);
@property(nonatomic,copy) void(^actionSheetCompletionBlock)(UIActionSheet *actionSheet ,NSInteger index);


/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Void
 Functionality : To Show Alert With only Ok Default Button in button options, usually use to just display the message and by pressing ok to dismiss it. For more buttons in Alert use other AlertView methods
 
 ------------------------------------------------------*/

+ (void) showOKAlertWithTitle:(NSString*)aTitle message:(NSString*)aMsg;

/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Void
 Functionality : To Show Alert With Title, Message, Delegate and Button Titles.
 
 ------------------------------------------------------*/

+ (void) showAlertView :(NSString*)title message:(NSString*)msg delegate:(id)delegate cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles;

/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Void
 Functionality : To Show Alert With only Ok Default Button in button options, usually use to just display the message and by pressing ok to dismiss it. For more buttons in Alert use other AlertView methods
 
 ------------------------------------------------------*/

+ (void) showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)msg delegate:(id)delegate
			cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles;

+ (UIButton *)newButtonWithTarget:(id)target
						 selector:(SEL)selector
							frame:(CGRect)frame
							image:(UIImage *)image
					selectedImage:(UIImage *)selectedImage
							  tag:(NSInteger)aTag;
+(UITextField*) createTextFieldWithTag:(NSInteger)aTag startX:(CGFloat)aX startY:(CGFloat)aY width:(CGFloat)aW height:(CGFloat)aH placeHolder:(NSString*)aPl keyBoard:(BOOL)isNumber;
+(UILabel*) createNewLabelWithTag:(NSInteger)aTag startX:(CGFloat)aX startY:(CGFloat)aY width:(CGFloat)aW height:(CGFloat)aH text:(NSString*)aText noOfLines:(NSInteger)noOfLine;

+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(int) maxWidth maxHeight:(int) maxHeight;
+ (NSString*) stringFromImage:(UIImage*)image;
+ (UIImage*) imageFromString:(NSString*)imageString;
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image ;
+ (void) addLabelOnNavigationBarWithTitle:(NSString*)aTitle OnNavigation:(UINavigationController*)naviController;

+(BOOL)emailValidate:(NSString *)email;

// -----------------------------------------------------------------------------------------------

+(UILabel*) createNewBLabelWithTag:(NSInteger)aTag startX:(CGFloat)aX startY:(CGFloat)aY width:(CGFloat)aW height:(CGFloat)aH text:(NSString*)aText noOfLines:(NSInteger)noOfLine;
+(UIImageView*) createImageViewWithTag:(NSInteger)aTag startX:(CGFloat)aX startY:(CGFloat)aY width:(CGFloat)aW height:(CGFloat)aH image:(NSString*)aText;
+ (UIButton *)createButtonWithTarget:(id)target
                            selector:(SEL)selector
                               frame:(CGRect)frame
                         bgimageName:(NSString *)imageName
                                 tag:(NSInteger)aTag;

//-----------------------------------------------------------------------------------------------
+(void) startActivityIndicatorInView:(UIView*)aView withMessage:(NSString*)aMessage;
+(void) stopActivityIndicatorInView:(UIView*)aView;

//-----------------------------------------------------------------------------------
+ (BOOL) isiPad;
+ (UIColor *) colorWithHexString: (NSString *) hex;
//-----------------------------------------------------------------------------------
+  (CGSize) calculateLabelHeightWith:(CGFloat)width text:(NSString*)textString;
+ (CGSize) calculateLabelWidthOfString:(NSString*)textString withFont:(UIFont*)font;
+ (void)fadeInAndFadeOutAnaimationWithView:(UIView*)aView;
+ (NSDate*) dateFromString:(NSString*)aStr;
+(NSDictionary*) getLocationLatiLongiValueFromAddress:(NSString*)address;
+(NSDate*)getCurrentSystemDate;
+(NSString *)localDateForGmtDate:(NSDate *)messageDate;
+ (void) showAlertViewWithTextFieldTag:(NSInteger)tag title:(NSString*)title message:(NSString*)msg delegate:(id)delegate
                     cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles;
+(void)openActionSheetWithTag:(NSInteger)tag delegate:(id)delegate buttons:(NSArray *)buttons;
+(void)animateUpTextField:(UITextField *)textField inView:(UIView *)view;
+(void)animateDownTextField:(UITextField *)textField inView:(UIView *)view;
+(void)playVideo:(NSString *)videoFile viewController:(UIViewController *)viewController;
+(void)openImagePickerController:(UIImagePickerControllerSourceType)sourceType delegate:(id)delegate;
+(UIImage *)generateThumbNailOfVideo:(NSURL *)videoUrl;
+(NSString *)localDateForGmtDateString:(NSString *)messageDate;
+(void)addPickerWithToolBarFrame:(UIView *)picker toolBar:(UIToolbar *)doneToolBar inView:(UIView *)view;

@end
