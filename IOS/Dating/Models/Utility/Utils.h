//
//  Utils.h
//  Dating
//
//  Created by Harsh Sharma on 7/29/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject <UIActionSheetDelegate>


@property(assign,nonatomic)BOOL internetActive;
@property(nonatomic,copy) void(^alertCompletionBlock)(UIAlertView *alert ,NSInteger index);
@property(nonatomic,copy) void(^actionSheetCompletionBlock)(UIActionSheet *actionSheet ,NSInteger index);

#pragma mark ----
#pragma mark Singleton Instance

/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Class Type (Instance Type)
 Functionality : To Create a Singelton Object of Utils, which will be alive throughout the run of the app.
 
 ------------------------------------------------------*/

+ (Utils *)sharedInstance;

#pragma mark ----
#pragma mark UIAlertView Methods

/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : aTi
                 aTitle : (Title of Ok Button to display in Alert View)
                 aMsg : (Message to Display to the User)
 
 Return Type   : Void
 Functionality : To Show Alert With only Ok Default Button in button options, usually use to just display the message and by pressing ok to     
                 dismiss it. For more buttons in Alert use other AlertView methods
 
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
 Functionality : To Create Alert view With Tag and other options like in above one.
 
 ------------------------------------------------------*/

+ (void) showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)msg delegate:(id)delegate
			cancelButtonTitle:(NSString*)CbtnTitle otherButtonTitles:(NSString*)otherBtnTitles;

#pragma mark ----
#pragma mark UIImage Operations

/*-----------------------------------------------------
 
 Method Name   : sharedInstance
 Parameters    : nil
 Return Type   : Void
 Functionality : To .
 
 ------------------------------------------------------*/

+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(int) maxWidth maxHeight:(int) maxHeight;
+ (NSString*) stringFromImage:(UIImage*)image;
+ (UIImage*) imageFromString:(NSString*)imageString;
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image ;

#pragma mark ----
#pragma mark Field Validations

+(BOOL)emailValidate:(NSString *)email;
+(BOOL)isInternetAvailable;

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

-(void)openAlertViewWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons completion:(void(^)(UIAlertView *alert,NSInteger buttonIndex))alertBlock;

-(void)openActionSheetWithTitle:(NSString *)title buttons:(NSArray *)buttons completion:(void(^)(UIActionSheet *actionSheet,NSInteger buttonIndex))actionSheetBlock;

@end
