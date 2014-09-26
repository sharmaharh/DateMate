//
//  ContactsViewController.h
//  Dating
//
//  Created by Harsh Sharma on 9/20/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewContacts;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarContact;

@end
