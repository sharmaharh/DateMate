//
//  FindMatchViewController.m
//  Dating
//
//  Created by Harsh Sharma on 06/08/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "FindMatchViewController.h"

@interface FindMatchViewController ()
{
    NSArray *matchedProfilesArray;
    NSInteger currentIndex;
}
@end

@implementation FindMatchViewController

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
    [self findMatchesList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileOnLayout
{
    NSDictionary *profileDict = matchedProfilesArray[currentIndex];
    for (int i = 1; i < 4; i++)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.selected = NO;
    }
    self.profileNameLabel.text = [NSString stringWithFormat:@"%@,%@",profileDict[@"firstName"],profileDict[@"age"]];
    [self.profileImageView setImage:nil];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileDict[@"pPic"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError)
        {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.profileImageView setImage:image];
            }
            
        }
        else
        {
            
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

- (void)findMatchesList
{
    matchedProfilesArray = [NSMutableArray array];
    
    AFNHelper *afnhelper = [AFNHelper new];
    [afnhelper getDataFromPath:@"findMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID} mutableCopy] withBlock:^(id response, NSError *error)
    {
        if (![[response objectForKey:@"errFlag"] boolValue])
        {
            if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
            {
                matchedProfilesArray = [response objectForKey:@"matches"];
                [self setProfileOnLayout];
            }
            else
            {
                matchedProfilesArray = [NSMutableArray array];
            }
        }
        
    }];
}

- (IBAction)passProfileButtonPressed:(id)sender
{
    currentIndex++;
    if (currentIndex < matchedProfilesArray.count)
    {
        [self setProfileOnLayout];
    }
    else
    {
        [Utils showOKAlertWithTitle:@"Dating" message:@"Sorry, Boss No More Entry Available"];
    }
    
}

- (IBAction)passEmotionsButtonPressed:(id)sender
{
    UIButton *emotionsButton = (UIButton *)sender;
    
    AFNHelper *afnhelper = [AFNHelper new];
    NSMutableDictionary *requestDic = [NSMutableDictionary dictionaryWithObjects:@[[FacebookUtility sharedObject].fbID,matchedProfilesArray[currentIndex][@"fbId"],[NSString stringWithFormat:@"%i",emotionsButton.tag]] forKeys:@[@"ent_user_fbid",@"ent_invitee_fbid",@"ent_user_action"]];
    
    [afnhelper getDataFromPath:@"inviteAction" withParamData:requestDic withBlock:^(id response, NSError *error)
     {
         emotionsButton.selected = YES;
         
//         if ([[response objectForKey:@"errFlag"] boolValue])
//         {
//             if ([[response objectForKey:@"matches"] isKindOfClass:[NSArray class]])
//             {
//                 matchedProfilesArray = [response objectForKey:@"matches"];
//                 [self setProfileOnLayout];
//             }
//             else
//             {
//                 matchedProfilesArray = [NSMutableArray array];
//             }
//         }
         
     }];
    
}
- (IBAction)btnRevealPressed:(id)sender
{
    [self.revealViewController revealToggle:self];
}
@end
