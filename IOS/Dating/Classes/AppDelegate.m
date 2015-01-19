//
//  AppDelegate.m
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "FindMatchViewController.h"
#import "RearMenuViewController.h"
#import "RecentChatsViewController.h"
#import "SelectGenderViewController.h"
#import "SelectTastesViewController.h"
#import "KeepingConnectingViewController.h"
#import "ChatPartners.h"

@implementation AppDelegate

AppDelegate* appDelegate = nil;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    appDelegate = self;
    
    appDelegate.userPreferencesDict = [NSMutableDictionary dictionary];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"UserPreferences"] count])
    {
        appDelegate.userPreferencesDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserPreferences"] mutableCopy];
    }
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    
    NSDictionary *serverNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (serverNotif)
    {
        // After Recieving Push Notification, go to Message View controller
        [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
        NSLog(@"Server Notification = %@",serverNotif);
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if ([serverNotif[@"aps"][@"alert"] isEqualToString:@"1"])
            {

                KeepingConnectingViewController *keepConnectingViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"KeepingConnectingViewController"];
                self.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:keepConnectingViewController];
                [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
                [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
                
                self.revealController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ResideMenuViewController"];
                self.revealController.contentViewController = self.frontNavigationController;
                [self.window setRootViewController:self.revealController];

            }
            else
            {
                RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                recentChatViewController.isFromPush = YES;
                self.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
                
                [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
                [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
                
                self.revealController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ResideMenuViewController"];
                self.revealController.contentViewController = self.frontNavigationController;
                [self.window setRootViewController:self.revealController];
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSDictionary *messageDict = @{msg_text: serverNotif[@"aps"][@"alert"], msg_Date: serverNotif[@"aps"][msg_Date], msg_ID: serverNotif[@"aps"][msg_ID], msg_Reciver_ID: [FacebookUtility sharedObject].fbID, msg_Sender_ID: serverNotif[@"aps"][@"sFid"],msg_Sender_Name: serverNotif[@"aps"][msg_Sender_Name],msg_Media_Section: serverNotif[@"aps"][@"mt"]};
                    [[ChatViewController sharedChatInstance] recieveMessage:serverNotif[@"aps"]];
                    [[ChatViewController sharedChatInstance] addMessageToDatabase:[Message messageWithDictionary:messageDict]];
                });
            }
            
            
        });
        
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LoginPersistingClass"] length])
        {
            self.frontNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FirstNavigationController"];
            [self.frontNavigationController setNavigationBarHidden:YES];
            [self.frontNavigationController pushViewController:[mainStoryBoard instantiateViewControllerWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"LoginPersistingClass"]] animated:NO];
            [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
            [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
            self.window.rootViewController = self.frontNavigationController;
        }
        else
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"] length])
            {
                // Find Match
                
                FindMatchViewController *findMatchViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
                self.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
                [self.frontNavigationController setNavigationBarHidden:YES];
                [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
                [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
                
                self.revealController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ResideMenuViewController"];
                self.revealController.contentViewController = self.frontNavigationController;
                [self.window setRootViewController:self.revealController];
                
            }
            else
            {
                // Login
                self.frontNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FirstNavigationController"];
                [self.frontNavigationController setNavigationBarHidden:YES];
                self.window.rootViewController = self.frontNavigationController;
            }
        }
        
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)getSplashImages
{
    AFNHelper *afnHelper = [AFNHelper new];
    [afnHelper getDataFromPath:@"splashImages" withParamData:nil withBlock:^(id response, NSError *error) {
        
        if ([[response objectForKey:@"Userphotos"] count])
        {
            NSArray *imageURLArray = [response objectForKey:@"Userphotos"];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *basePath = [paths objectAtIndex:0];
            
            basePath = [basePath stringByAppendingPathComponent:@"Splash_Images"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:basePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:basePath error:nil];
            }
            
            [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
            
            for (NSDictionary *dict in imageURLArray)
            {
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dict[@"image_url"]]] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    
                    if (!connectionError)
                    {
                        UIImage *image = [UIImage imageWithData:data];
                        
                        if (image)
                        {
                            
                            NSString *filePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.png",[imageURLArray indexOfObject:dict]+1]];
                            
                            [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
                            
                            
                        }
                    }
                    
                    
                }];
            }
        }
        
        
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.isAppinBackground = YES;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    self.isAppinBackground = NO;
    
    if ([[appDelegate.frontNavigationController topViewController] isKindOfClass:[SelectTastesViewController class]] || [[appDelegate.frontNavigationController topViewController] isKindOfClass:[SelectGenderViewController class]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([[appDelegate.frontNavigationController topViewController] class]) forKey:@"LoginPersistingClass"];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"LoginPersistingClass"];
    }
    if (appDelegate.userPreferencesDict)
    {
        [[NSUserDefaults standardUserDefaults] setObject:appDelegate.userPreferencesDict forKey:@"UserPreferences"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark-  Push Notification Method

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    NSString *devToken = [[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""];
    devToken = [devToken stringByReplacingOccurrencesOfString: @">" withString: @""] ;
    devToken = [devToken stringByReplacingOccurrencesOfString: @" " withString:@""];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:devToken forKey:@"deviceToken"];
    [userDefaults synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [Utils showOKAlertWithTitle:@"DateMate" message:error.localizedDescription];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Server Notification = %@",userInfo);
    
    UINavigationController *frontNavigationController = (id)self.revealController.contentViewController;
    [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
    
    if ([userInfo[@"aps"][@"nt"] isEqualToString:@"2"])
    {
        NSString *msgType = nil;
        if ([userInfo[@"aps"][@"msgtype"] intValue] == 1 || [userInfo[@"aps"][@"msgtype"] intValue] == 2)
        {
            msgType = @"1";
        }
        else
        {
            msgType = [NSString stringWithFormat:@"%i",[userInfo[@"aps"][@"msgtype"] intValue]-1];
        }
        NSDictionary *messageDict = @{msg_text: userInfo[@"aps"][@"alert"], msg_Date: userInfo[@"aps"][msg_Date], msg_ID: userInfo[@"aps"][msg_ID], msg_Reciver_ID: [FacebookUtility sharedObject].fbID, msg_Sender_ID: userInfo[@"aps"][@"sFid"],msg_Sender_Name: userInfo[@"aps"][msg_Sender_Name],msg_Media_Section:msgType};
        if ([frontNavigationController.topViewController isKindOfClass:[ChatViewController class]])
        {
            ChatViewController *chatViewController = (ChatViewController *)frontNavigationController.topViewController;
            if ([chatViewController.recieveFBID isEqualToString:userInfo[@"aps"][@"sFid"]])
            {
                [chatViewController recieveMessage:messageDict];
            }
           
            [chatViewController addMessageToDatabase:[Message messageWithDictionary:messageDict]];
        }
        else if (self.isAppinBackground)
        {
            self.isAppinBackground = NO;
            if ([frontNavigationController.topViewController isKindOfClass:[RecentChatsViewController class]])
            {
                [frontNavigationController pushViewController:[ChatViewController sharedChatInstance] animated:YES];
                
                
            }
            else
            {
                UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
                recentChatViewController.isFromPush = YES;
                
                [appDelegate.revealController setContentViewController:frontNavigationController animated:YES];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [[ChatViewController sharedChatInstance] recieveMessage:userInfo[@"aps"]];
                    [[ChatViewController sharedChatInstance] addMessageToDatabase:[Message messageWithDictionary:messageDict]];
                });
            }
        }
        else
        {
            
            [[ChatViewController sharedChatInstance] addMessageToDatabase:[Message messageWithDictionary:messageDict]];
            // Update Badge Counter
            
            if (![frontNavigationController.topViewController isKindOfClass:[ChatViewController class]])
            {
                [self updateBadgeCounterWithInfo:userInfo[@"aps"]];
                
            }
            
            if ([frontNavigationController.topViewController isKindOfClass:[RecentChatsViewController class]])
            {
                RecentChatsViewController *recentChatViewController = (RecentChatsViewController *)frontNavigationController.topViewController;
                
                [recentChatViewController getRecentChatUsers];
            }            
        }
    }
    
    else
    {
        
        if ([frontNavigationController.topViewController isKindOfClass:[KeepingConnectingViewController class]])
        {
            [Utils showOKAlertWithTitle:@"Dating" message:userInfo[@"aps"][@"alert"]];
            
        }
        else
        {
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            KeepingConnectingViewController *keepConnectingViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"KeepingConnectingViewController"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:keepConnectingViewController];
            [appDelegate.revealController setContentViewController:navigationController animated:YES];
            
        }

    }
    
}

- (NSInteger)indexOfObjectWithSenderID:(NSString *)sFid InArray:(NSMutableArray *)nameArray
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject[@"sFid"] isEqualToString:sFid];
    }];
    NSDictionary *userInfoDict = [[nameArray filteredArrayUsingPredicate:predicate] firstObject];
    return [nameArray indexOfObject:userInfoDict];
}

- (void)updateBadgeCounterWithInfo:(NSDictionary *)infoDict
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ChatPartners"];
    NSPredicate *chatPredicate  = [NSPredicate predicateWithFormat:@"%K = %@",@"fbId",infoDict[@"sFid"]];
    
    [request setPredicate:chatPredicate];
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count])
    {
        ChatPartners *chatParterns = results[0];
        chatParterns.unreadCount = [NSNumber numberWithInt:[chatParterns.unreadCount intValue]+1];
        [appDelegate.managedObjectContext save:nil];
    }
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Dating" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Dating.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
