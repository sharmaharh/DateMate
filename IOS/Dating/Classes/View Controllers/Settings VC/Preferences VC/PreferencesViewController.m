//
//  PreferencesViewController.m
//  Dating
//
//  Created by Harsh Sharma on 05/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "PreferencesViewController.h"
#import "FindMatchViewController.h"
#import "PBJHexagonFlowLayout.h"
#import "NMRangeSlider.h"
#define TextView_PlaceHolder @"Enter status here."

@interface PreferencesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray *preferenceComponentsArray;
    NSMutableArray *preferencesArray;
    UIView *maleFemaleView;
    UIView *notificationOnOffView;
    UIView *aboutMeView;
    UIView *radiusView;
    UIView *ageView;
    UIView *soundOnOffView;
    NSMutableDictionary *currentPreferencesDict;
}
@end

@implementation PreferencesViewController

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
    preferenceComponentsArray = @[@"Preferences",@"Interested In",@"About Me",@"Radius (In kms)",@"Age Range (In Years)",@"Happy Going Famous"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    preferencesArray = [NSMutableArray arrayWithArray:[appDelegate.userPreferencesDict[@"ent_pref_lifestyle"] componentsSeparatedByString:@","]];
    currentPreferencesDict = [appDelegate.userPreferencesDict mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)buttonSubmitPrefferencesPressed:(id)sender
{
    
    if (![Utils isInternetAvailable])
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:NO_INERNET_MSG];
    }
    else
    {

        
        AFNHelper *afnhelper = [AFNHelper new];
        [afnhelper getDataFromPath:@"updatePreferences" withParamData:currentPreferencesDict withBlock:^(id response, NSError *error)
        {
            appDelegate.userPreferencesDict = currentPreferencesDict;
            FindMatchViewController *findMatchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
            [navigationController setNavigationBarHidden:YES];
            [appDelegate.revealController setContentViewController:navigationController animated:YES];
            
            NSLog(@"%@",response);
        }];
    }

}



#pragma mark UITextField Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
//    [keyboardDoneButtonView sizeToFit];
//    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
//                                                                   style:UIBarButtonItemStyleBordered target:self
//                                                                  action:@selector(doneClicked:)];
//    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
//    textView.inputAccessoryView = keyboardDoneButtonView;
    if ([textView.text isEqualToString:TextView_PlaceHolder])
    {
        textView.text = @"";
    }
    [textView setTextColor:[UIColor whiteColor]];
    [self.preferencesTableView setContentOffset:CGPointMake(self.preferencesTableView.contentOffset.x, self.preferencesTableView.contentOffset.y + textView.frame.size.height -[self calculateTextViewOffsetAccordingToKeyboard:textView]) animated:YES];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(([text isEqualToString:@"\n"]))
    {
        [textView resignFirstResponder];
        [self.preferencesTableView setContentOffset:CGPointMake(self.preferencesTableView.contentOffset.x, self.preferencesTableView.contentSize.height-self.preferencesTableView.frame.size.height) animated:YES];
        [currentPreferencesDict setObject:textView.text forKey:@"ent_pers_desc"];
        return YES;
    }
    
    if (textView.text.length + [text length] > 140)
    {
        [Utils showOKAlertWithTitle:_Alert_Title message:@"Please enter status in less than 140 characters"];
        return NO;
    }
    else
    {
        [currentPreferencesDict setObject:[textView.text stringByReplacingCharactersInRange:range withString:text] forKey:@"ent_pers_desc"];
        return YES;
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    if (!textView.text.length)
    {
        textView.attributedText = [[NSAttributedString alloc] initWithString:TextView_PlaceHolder attributes:@{NSFontAttributeName : textView.font, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    }
    [self.preferencesTableView setContentOffset:CGPointMake(self.preferencesTableView.contentOffset.x, self.preferencesTableView.contentSize.height-self.preferencesTableView.frame.size.height) animated:YES];
    return YES;
}

//- (void)doneClicked:(id)sender
//{
//    [self.view endEditing:YES];
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
//    }];
//}

- (CGFloat)calculateTextViewOffsetAccordingToKeyboard:(UITextView *)textView
{
    CGRect newRect = [self.view convertRect:textView.frame fromView:[textView superview]];
    CGFloat yDifference = 320 - newRect.origin.y;
    return yDifference;
}

#pragma UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark -----
#pragma mark UITableViewDelegate & DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    return [preferenceComponentsArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 44)];
    [headerView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.4]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-10, 44)];
    [headerLabel setText:preferenceComponentsArray[section]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
    
    UILabel *underlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5, self.view.frame.size.width, 0.5)];
    [underlineLabel setBackgroundColor:[UIColor whiteColor]];
    [headerView addSubview:underlineLabel];
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5)
    {
        return 80;
    }
    else
        return indexPath.section?60:330;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    switch (indexPath.section)
    {
        case 0:
            // Preferences View
            [cell.contentView addSubview:[self addUserPotraitsView]];
            break;
            
        case 1:
            // Interested In
            [cell.contentView addSubview:[self addUserInterestedInView]];
            break;
            
        case 2:
            // About Me
            [cell.contentView addSubview:[self addUserAboutMeView]];
            break;
            
        case 3:
            // Radius
            [cell.contentView addSubview:[self addRadiusSilder]];
            break;
            
        case 4:
            // Age Range
            [cell.contentView addSubview:[self addAgeSilder]];
            break;
        
        case 5:
        {
            // Want to be famous
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = @"Happy Going Famous";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            [cell.textLabel setFont:[UIFont fontWithName:@"SegoeUI" size:16]];
            cell.detailTextLabel.text = @"You could be lucky user to view yourself on All Yocty Users application splash screen. Do you want to be on their Welcome Screen?";
            [cell.detailTextLabel setNumberOfLines:3];
            [cell.detailTextLabel setFont:[UIFont fontWithName:@"SegoeUI" size:10]];
            UISwitch *onOffSwitch = [[UISwitch alloc] init];
            onOffSwitch.tag = 12;
            onOffSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"Famous"];
            [onOffSwitch addTarget:self action:@selector(splashOnOffValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = onOffSwitch;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)splashOnOffValueChanged:(UISwitch *)splashSwitch
{
    [currentPreferencesDict setObject:splashSwitch.on?@"1":@"2" forKey:@"ent_pref_show_photo"];
    [[NSUserDefaults standardUserDefaults] setBool:splashSwitch.on forKey:@"Famous"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIView *)addUserPotraitsView
{
    PBJHexagonFlowLayout *flowLayout = [[PBJHexagonFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.itemSize = CGSizeMake(90.0f, 100.0f);
    flowLayout.itemsPerRow = 8;
    _collectionViewPreferences.frame = CGRectMake(10, 10, 310, 320);
    [_collectionViewPreferences setCollectionViewLayout:flowLayout];
    return _collectionViewPreferences;
}

- (UIView *)addUserInterestedInView
{
    UIButton *maleCheckBoxButton = nil;
    UIButton *femaleCheckBoxButton = nil;
    UIButton *bothCheckBoxButton = nil;
    
    if (!maleFemaleView)
    {
        maleFemaleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        maleCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        maleCheckBoxButton.frame = CGRectMake(20, 15, 80, 30);
        [maleCheckBoxButton setTitle:@"Male" forState:UIControlStateNormal];
        [maleCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [maleCheckBoxButton setTag:3];
        [maleCheckBoxButton.layer setBorderWidth:1.0];
        [maleCheckBoxButton.layer setCornerRadius:maleCheckBoxButton.frame.size.height/2];
        
        femaleCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        femaleCheckBoxButton.frame = CGRectMake(120, 15, 80, 30);
        [femaleCheckBoxButton setTitle:@"Female" forState:UIControlStateNormal];
        [femaleCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [femaleCheckBoxButton setTag:4];
        [femaleCheckBoxButton.layer setBorderWidth:1.0];
        [femaleCheckBoxButton.layer setCornerRadius:femaleCheckBoxButton.frame.size.height/2];
        
        bothCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bothCheckBoxButton.frame = CGRectMake(220, 15, 80, 30);
        [bothCheckBoxButton setTitle:@"Both" forState:UIControlStateNormal];
        [bothCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [bothCheckBoxButton setTag:5];
        [bothCheckBoxButton.layer setBorderWidth:1.0];
        [bothCheckBoxButton.layer setCornerRadius:bothCheckBoxButton.frame.size.height/2];
        [bothCheckBoxButton addTarget:self action:@selector(maleFemaleOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [maleCheckBoxButton addTarget:self action:@selector(maleFemaleOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [femaleCheckBoxButton addTarget:self action:@selector(maleFemaleOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [maleFemaleView addSubview:maleCheckBoxButton];
        [maleFemaleView addSubview:femaleCheckBoxButton];
        [maleFemaleView addSubview:bothCheckBoxButton];
    }
    else
    {
        maleCheckBoxButton = (UIButton *)[maleFemaleView viewWithTag:3];
        femaleCheckBoxButton = (UIButton *)[maleFemaleView viewWithTag:4];
        bothCheckBoxButton = (UIButton *)[maleFemaleView viewWithTag:5];

    }
    
    
    if(([appDelegate.userPreferencesDict[@"ent_pref_sex"] intValue] + 2) == maleCheckBoxButton.tag)
    {
        [maleCheckBoxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [maleCheckBoxButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        [femaleCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [femaleCheckBoxButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        
        [bothCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [bothCheckBoxButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];

    }
    else if (([appDelegate.userPreferencesDict[@"ent_pref_sex"] intValue] + 2) == femaleCheckBoxButton.tag)
    {
        [femaleCheckBoxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [femaleCheckBoxButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        [maleCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [maleCheckBoxButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        
        [bothCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [bothCheckBoxButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];

    }
    else
    {
        [bothCheckBoxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bothCheckBoxButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        [maleCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [maleCheckBoxButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        
        [femaleCheckBoxButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [femaleCheckBoxButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    }
    
    
    return maleFemaleView;
}

- (UIView *)addUserAboutMeView
{
    if (!aboutMeView)
    {
        aboutMeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        UITextView *statusTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 40)];
        [statusTextView setTextColor:[UIColor blueColor]];
        [statusTextView setText:appDelegate.userPreferencesDict[@"ent_pers_desc"]];
        [statusTextView setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
        if (!statusTextView.text.length)
        {
            statusTextView.attributedText = [[NSAttributedString alloc] initWithString:TextView_PlaceHolder attributes:@{NSFontAttributeName : statusTextView.font, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        }
        statusTextView.tag = 6;
        [statusTextView setDelegate:self];
        [statusTextView setBackgroundColor:[UIColor clearColor]];
        
        [aboutMeView addSubview:statusTextView];
    }
    
    return aboutMeView;
}

- (UIView *)addNotificationOptionView
{
    UIButton *notificationOnButton = nil;
    UIButton *notificationOffButton = nil;
    
    if (!notificationOnOffView)
    {
        notificationOnOffView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        notificationOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        notificationOnButton.frame = CGRectMake(20, 15, 40, 30);
        [notificationOnButton setTitle:@"On" forState:UIControlStateNormal];
        [notificationOnButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [notificationOnButton setTag:5];
        [notificationOnButton.layer setBorderWidth:1.0];
        [notificationOnButton.layer setCornerRadius:notificationOnButton.frame.size.height/2];
        
        notificationOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
        notificationOffButton.frame = CGRectMake(80, 15, 40, 30);
        [notificationOffButton setTitle:@"Off" forState:UIControlStateNormal];
        [notificationOffButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [notificationOffButton setTag:6];
        [notificationOffButton.layer setBorderWidth:1.0];
        [notificationOffButton.layer setCornerRadius:notificationOffButton.frame.size.height/2];
        [notificationOffButton addTarget:self action:@selector(notificationOnOffOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [notificationOnButton addTarget:self action:@selector(notificationOnOffOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [notificationOnOffView addSubview:notificationOffButton];
        [notificationOnOffView addSubview:notificationOnButton];
    }
    else
    {
        notificationOnButton = (UIButton *)[notificationOnOffView viewWithTag:5];
        notificationOffButton = (UIButton *)[notificationOnOffView viewWithTag:6];
    }
    

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"Notifications"])
    {
        [notificationOnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [notificationOnButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [notificationOffButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [notificationOffButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        
    }
    else
    {
        [notificationOnButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [notificationOnButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [notificationOffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [notificationOffButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
    
    return notificationOnOffView;
}

- (UIView *)addAgeSilder
{
    if (!ageView)
    {
        ageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        NMRangeSlider* rangeSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(20, 25, self.view.frame.size.width-40, 30)];
        rangeSlider.maximumValue = 30;
        rangeSlider.minimumValue = 18;
        
        rangeSlider.lowerValue = [appDelegate.userPreferencesDict[@"ent_pref_lower_age"] intValue];
        rangeSlider.upperValue = [appDelegate.userPreferencesDict[@"ent_pref_upper_age"] intValue];
        
        rangeSlider.tag = 9;
        [rangeSlider addTarget:self action:@selector(labelSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self configureMetalThemeForSlider:rangeSlider];
        [ageView addSubview:rangeSlider];
        [rangeSlider setNeedsLayout];
        // Add Lower Label
        
        UILabel *lowerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 20, 12)];
        [lowerLabel setTextAlignment:NSTextAlignmentCenter];
        [lowerLabel setFont:[UIFont fontWithName:@"SegoeUI" size:12]];
        [lowerLabel setTextColor:[UIColor whiteColor]];
        lowerLabel.tag = 10;
        [lowerLabel setText:[NSString stringWithFormat:@"%i",(int)rangeSlider.lowerValue]];
        
        // Add Upper Label
        
        UILabel *upperLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-30, 12, 20, 12)];
        upperLabel.tag = 11;
        [upperLabel setTextAlignment:NSTextAlignmentCenter];
        [upperLabel setFont:[UIFont fontWithName:@"SegoeUI" size:12]];
        [upperLabel setTextColor:[UIColor whiteColor]];
        [upperLabel setText:[NSString stringWithFormat:@"%i",(int)rangeSlider.upperValue]];
        [ageView addSubview:lowerLabel];
        [ageView addSubview:upperLabel];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateSliderLabels];
        });
        
        
    }
    
    return ageView;
}

- (void) configureMetalThemeForSlider:(NMRangeSlider*) slider
{
    UIImage* image = nil;
    
    image = [UIImage imageNamed:@"slider-metal-trackBackground"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    slider.trackBackgroundImage = nil;
    
    image = [UIImage imageNamed:@"slider-metal-track"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    slider.trackImage = nil;
    
    image = [UIImage imageNamed:@"slider-metal-handle"];
    image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 2, 1, 2)];
    slider.lowerHandleImageNormal = image;
    slider.upperHandleImageNormal = image;
    
    image = [UIImage imageNamed:@"slider-metal-handle-highlighted"];
    image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 2, 1, 2)];
    slider.lowerHandleImageHighlighted = image;
    slider.upperHandleImageHighlighted = image;
}

- (UIView *)addRadiusSilder
{
    if (!radiusView)
    {
        radiusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        UISlider *radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 15, self.view.frame.size.width-20, 20)];
        radiusSlider.tag = 7;
        radiusSlider.maximumValue = 1000;
        radiusSlider.minimumValue = 1;
        [radiusSlider addTarget:self action:@selector(radiusSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        radiusSlider.value = [appDelegate.userPreferencesDict[@"ent_pref_radius"] intValue];
        
        UILabel *upperLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 40, 20)];
        upperLabel.center = CGPointMake(radiusView.center.x, upperLabel.center.y);
        upperLabel.tag = 8;
        [upperLabel setTextAlignment:NSTextAlignmentCenter];
        [upperLabel setFont:[UIFont fontWithName:@"SegoeUI" size:16]];
        [upperLabel setTextColor:[UIColor whiteColor]];
        [upperLabel setText:[NSString stringWithFormat:@"%i",(int)radiusSlider.value]];
        
        [radiusView addSubview:radiusSlider];
        [radiusView addSubview:upperLabel];
    }
    return radiusView;
}

- (UIView *)addSoundOptionView
{
    UIButton *soundOnButton = nil;
    UIButton *soundOffButton = nil;
    
    if (!soundOnOffView)
    {
        soundOnOffView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        soundOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        soundOnButton.frame = CGRectMake(20, 15, 40, 30);
        [soundOnButton setTitle:@"On" forState:UIControlStateNormal];
        [soundOnButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [soundOnButton setTag:7];
        [soundOnButton.layer setBorderWidth:1.0];
        [soundOnButton.layer setCornerRadius:soundOnButton.frame.size.height/2];
        
        soundOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
        soundOffButton.frame = CGRectMake(80, 15, 40, 30);
        [soundOffButton setTitle:@"Off" forState:UIControlStateNormal];
        [soundOffButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [soundOffButton setTag:8];
        [soundOffButton.layer setBorderWidth:1.0];
        [soundOffButton.layer setCornerRadius:soundOffButton.frame.size.height/2];
        [soundOffButton addTarget:self action:@selector(soundOnOffOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [soundOnButton addTarget:self action:@selector(soundOnOffOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [soundOnOffView addSubview:soundOffButton];
        [soundOnOffView addSubview:soundOnButton];
    }
    else
    {
        soundOnButton = (UIButton *)[soundOnOffView viewWithTag:7];
        soundOffButton = (UIButton *)[soundOnOffView viewWithTag:8];
    }
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"Sounds"])
    {
        [soundOnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [soundOnButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [soundOffButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [soundOffButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        
    }
    else
    {
        [soundOnButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [soundOnButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [soundOffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [soundOffButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
    
    return soundOnOffView;
}

- (void)maleFemaleOptionPressed:(UIButton *)genderBtn
{
    UIButton *other1Button = nil;
    UIButton *other2Button = nil;
    [currentPreferencesDict setObject:[NSString stringWithFormat:@"%li",(long)genderBtn.tag-2] forKey:@"ent_pref_sex"];
    if (genderBtn.tag == 3)
    {
        other1Button = (UIButton *)[[genderBtn superview] viewWithTag:4];
        other2Button = (UIButton *)[[genderBtn superview] viewWithTag:5];
    }
    else if (genderBtn.tag == 4)
    {
        other1Button = (UIButton *)[[genderBtn superview] viewWithTag:3];
        other2Button = (UIButton *)[[genderBtn superview] viewWithTag:5];
    }
    else
    {
        other1Button = (UIButton *)[[genderBtn superview] viewWithTag:3];
        other2Button = (UIButton *)[[genderBtn superview] viewWithTag:4];
    }
    
    [genderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [genderBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [other1Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [other1Button.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    [other2Button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [other2Button.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
}

- (void)notificationOnOffOptionPressed:(UIButton *)notificationBtn
{
    UIButton *otherBtn = (UIButton *)((notificationBtn.tag == 5) ? [[notificationBtn superview] viewWithTag:6] : [[notificationBtn superview] viewWithTag:5]);
    [currentPreferencesDict setObject:[NSString stringWithFormat:@"%li",(long)notificationBtn.tag-5] forKey:@"ent_send_notify"];
    [notificationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [otherBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [otherBtn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [notificationBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
}

- (void)soundOnOffOptionPressed:(UIButton *)soundBtn
{
    UIButton *otherBtn = (UIButton *)((soundBtn.tag == 7) ? [[soundBtn superview] viewWithTag:8] : [[soundBtn superview] viewWithTag:7]);
    
    [soundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [otherBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [otherBtn.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [soundBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
}

- (void)radiusSliderValueChanged:(UISlider*)sender
{
    UILabel *radiusLabel = (UILabel *)[radiusView viewWithTag:8];
    [radiusLabel setText:[NSString stringWithFormat:@"%i",(int)sender.value]];
    [currentPreferencesDict setObject:radiusLabel.text forKey:@"ent_pref_radius"];
}


// Handle control value changed events just like a normal slider
- (void)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    NMRangeSlider *ageRangeSlider = (NMRangeSlider *)[ageView viewWithTag:9];
    UILabel *lowerValueLabel = (UILabel *)[ageView viewWithTag:10];
    UILabel *upperValueLabel = (UILabel *)[ageView viewWithTag:11];

    CGPoint lowerCenter;
    lowerCenter.x = (ageRangeSlider.lowerCenter.x + ageRangeSlider.frame.origin.x);
    lowerCenter.y = (ageRangeSlider.center.y - 25.0f);
    lowerValueLabel.center = lowerCenter;
    lowerValueLabel.text = [NSString stringWithFormat:@"%d", (int)ageRangeSlider.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (ageRangeSlider.upperCenter.x + ageRangeSlider.frame.origin.x);
    upperCenter.y = (ageRangeSlider.center.y - 25.0f);
    upperValueLabel.center = upperCenter;
    upperValueLabel.text = [NSString stringWithFormat:@"%d", (int)ageRangeSlider.upperValue];
    
    [currentPreferencesDict setObject:lowerValueLabel.text forKey:@"ent_pref_lower_age"];
    [currentPreferencesDict setObject:upperValueLabel.text forKey:@"ent_pref_upper_age"];
    
}

#pragma mark UICollectionView Delegate & Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [User_Preferences_Dict count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserQualityCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    [imageView setImage:[UIImage imageNamed:User_Preferences_Dict[[User_Preferences_Dict allKeys][indexPath.row]]]];
    
    UILabel *preferenceName = (UILabel *)[cell viewWithTag:2];
    preferenceName.numberOfLines = 2;
    NSString* string = [User_Preferences_Dict allKeys][indexPath.row];
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    CGSize strSize = [string boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont fontWithName:@"SegoeUI" size:14]} context:nil].size;

    style.minimumLineHeight = 12.0f;
    style.maximumLineHeight = 12.0f;
    style.lineSpacing = 0;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
    
    preferenceName.attributedText = [[NSAttributedString alloc] initWithString:string
                                                                    attributes:attributtes];
    [preferenceName setTextAlignment:NSTextAlignmentCenter];
    if (strSize.width > 68)
    {
        [preferenceName setFont:[UIFont fontWithName:@"SegoeUI" size:12]];
    }
    else
    {
        [preferenceName setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
    }
    
    [preferenceName setAdjustsFontSizeToFitWidth:YES];
    if ([preferencesArray containsObject:string])
    {
        cell.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:229.0f/255.0f alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
    }
    
    [Utils configureLayerForHexagonWithView:cell withBorderColor:[UIColor clearColor] WithCornerRadius:20 WithLineWidth:3 withPathColor:[UIColor clearColor]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (![preferencesArray containsObject:[User_Preferences_Dict allKeys][indexPath.row]])
    {
        // Make Selection
        cell.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:147.0f/255.0f blue:229.0f/255.0f alpha:1];
        [preferencesArray addObject:[User_Preferences_Dict allKeys][indexPath.row]];
    }
    else
    {
        // Deselect it
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.15];
        [preferencesArray removeObject:[User_Preferences_Dict allKeys][indexPath.row]];
    }
    [currentPreferencesDict setObject:[preferencesArray componentsJoinedByString:@","] forKey:@"ent_pref_lifestyle"];
}

- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
