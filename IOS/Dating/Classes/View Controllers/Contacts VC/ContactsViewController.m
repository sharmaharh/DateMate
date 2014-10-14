//
//  ContactsViewController.m
//  Dating
//
//  Created by Harsh Sharma on 9/20/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "ContactsViewController.h"
#import "ChatViewController.h"

@interface ContactsViewController ()
{
    NSMutableArray *contactsArray;
    NSInteger selectedIndex;
    NSArray *tempArray;
}
@end

@implementation ContactsViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"getProfileMatches" withParamData:[@{@"ent_user_fbid": [FacebookUtility sharedObject].fbID, @"ent_user_action": @"5"} mutableCopy] withBlock:^(id response, NSError *error)
     {
         /*
          likes =     (
          {
          fName = Rahul;
          fbId = 752656701440251;
          flag = 5;
          "flag_state" = 2;
          ladt = "2014-10-12 07:44:26";
          pPic = "http://incredtechnologies.com/playground/ws/pics/xffgdf.jpg";
          },
          {
          fName = Navneet;
          fbId = 10203175848489479;
          flag = 5;
          "flag_state" = 2;
          ladt = "2014-10-12 07:43:11";
          pPic = "http://incredtechnologies.com/playground/ws/pics/262217_3991638541793_1099481420_n.jpg";
          }
          );
          */
         if ([response[@"likes"] count])
         {
             contactsArray = response[@"likes"];
         }
         else
         {
             contactsArray = [NSMutableArray array];
         }
         tempArray = [contactsArray copy];
         [self.tableViewContacts reloadData];
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ChatViewController *chatViewController = [segue destinationViewController];
    chatViewController.userName = contactsArray[selectedIndex][@"fName"];
    chatViewController.recieveFBID = contactsArray[selectedIndex][@"fbId"];
}


#pragma mark -----
#pragma mark UITableViewDelegate & DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contactsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.textLabel.text = contactsArray[indexPath.row][@"fName"];
    cell.imageView.image = [UIImage imageNamed:@"Bubble-1"];
    cell.backgroundColor = [UIColor redColor];
    [self setImageOnTableViewCell:cell AtIndexPath:indexPath];
    return cell;
}

- (void)setImageOnTableViewCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infoDict = contactsArray[indexPath.row];
    if ([[infoDict allKeys] containsObject:@"pPic_Local"])
    {
        UIImage *cellImage = [UIImage imageWithContentsOfFile:infoDict[@"pPic_Local"]];
        if (cellImage)
        {
            cell.imageView.image = cellImage;
        }
        else
        {
            [self downloadImageFromURL:infoDict[@"pPic"] onCell:cell];
        }
    }
    else
    {
        [self downloadImageFromURL:infoDict[@"pPic"] onCell:cell];
    }
    
}

- (void)downloadImageFromURL:(NSString *)imageURL onCell:(UITableViewCell *)cell
{
    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    
    [NSURLConnection sendAsynchronousRequest:imageURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (!connectionError)
         {
             UIImage *cellImage = [UIImage imageWithData:data];
             if (cellImage)
             {
                 cell.imageView.image = cellImage;
             }
         }
     }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ContactsToChatIdentifier" sender:self];
}

#pragma mark UISearchBar Delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    contactsArray = [tempArray mutableCopy];
    
    if ([searchText length])
    {
        [contactsArray filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"fName"] hasPrefix:searchBar.text];
        }]];
    }
    [self.tableViewContacts reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

@end
