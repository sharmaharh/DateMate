//
//  AppDelegate.h
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "ResideMenuViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

extern AppDelegate *appDelegate;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) ResideMenuViewController *revealController;
@property (strong, nonatomic) UINavigationController *frontNavigationController;
@property (strong, nonatomic) NSMutableDictionary *userPreferencesDict;
@property (assign, nonatomic) BOOL isAppinBackground;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
