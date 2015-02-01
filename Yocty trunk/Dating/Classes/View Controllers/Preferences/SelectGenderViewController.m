//
//  SelectGenderViewController.m
//  Dating
//
//  Created by Harsh Sharma on 12/2/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "SelectGenderViewController.h"

@interface SelectGenderViewController ()

@end

@implementation SelectGenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)genderOptionPressed:(UIButton *)sender
{
    [appDelegate.userPreferencesDict setObject:[NSString stringWithFormat:@"%i",sender.tag] forKey:@"ent_pref_sex"];
    [self performSegueWithIdentifier:@"selectGenderToSetPreferencesIdentifier" sender:nil];
}

@end
