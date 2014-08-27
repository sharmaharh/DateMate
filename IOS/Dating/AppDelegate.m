//
//  AppDelegate.m
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "SWRevealViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SWRevealViewController *swRevealViewController = (SWRevealViewController*)[mainStoryBoard instantiateInitialViewController];
    
    self.revealController = swRevealViewController;
    
    NSDictionary *serverNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (serverNotif)
    {
        // After Recieving Push Notification, go to Message View controller
        NSLog(@"Server Notification = %@",serverNotif);
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            ChatViewController *messageVC = [ChatViewController sharedChatInstance];
            NSLog(@"Chat = %@",messageVC);
            messageVC.messages = [@[[Message messageWithString:serverNotif[@"aps"][@"alert"]]] mutableCopy];
            
            
            UINavigationController *frontNavigationController = (UINavigationController *)swRevealViewController.frontViewController;
            [frontNavigationController pushViewController:messageVC animated:YES];
            
        });
        
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
//    NSData *urlData=[NSKeyedArchiver archivedDataWithRootObject:url];
//    
//    NSString *scheme=url.scheme;
//    if([scheme isEqualToString:kTumblrScheme])
//    {
//        [UserDefaluts setObject:urlData forKey:kTumblrUrl];
//        [UserDefaluts setBool:YES forKey:kIsTumblrLink];
//        return [[TMAPIClient sharedInstance] handleOpenURL:url];
//        
//    }
//    
//    [UserDefaluts setObject:urlData forKey:kFacebookUrl];
//    [UserDefaluts setBool:YES forKey:kIsFacebookLink];
//    [UserDefaluts synchronize];
    
    // return [FBSession.activeSession handleOpenURL:url];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark-  Push Notification Method

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    NSString *devToken = [[deviceToken description]stringByReplacingOccurrencesOfString: @"<" withString: @""];
    devToken = [devToken stringByReplacingOccurrencesOfString: @">" withString: @""] ;
    devToken = [devToken stringByReplacingOccurrencesOfString: @" " withString:@""];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:devToken forKey:@"deviceToken"];
    [userDefaults synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [Utils showOKAlertWithTitle:@"DateMate" message:error.localizedDescription];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:@"1234" forKey:kDeviceToken];
//    [userDefaults synchronize];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

//    [self callLogOut];
    UINavigationController *frontNavigationController = (id)self.revealController.frontViewController;
    [Utils showOKAlertWithTitle:@"DateMate" message:@"Push Recieved"];
    if ( ![frontNavigationController.topViewController isKindOfClass:[ChatViewController class]] )
    {
        
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[ChatViewController sharedChatInstance]];
        [self.revealController pushFrontViewController:navigationController animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ChatViewController sharedChatInstance] recieveMessage:userInfo[@"aps"][@"alert"]];
        });
    }
    // Seems the user attempts to 'switch' to exactly the same controller he came from!
    else
    {
        [self.revealController revealToggle:self];
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
