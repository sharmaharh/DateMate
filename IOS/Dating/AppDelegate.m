//
//  AppDelegate.m
//  Dating
//
//  Created by Harsh Sharma on 7/26/14.
//  Copyright (c) 2014 IncredTechnologies. All rights reserved.
//

#import "AppDelegate.h"
//#import "SplashView.h"
#import "ChatViewController.h"
#import "FindMatchViewController.h"
#import "SWRevealViewController.h"
#import "RearMenuViewController.h"
#import "RecentChatsViewController.h"
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
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    // Condition Determines that if user is already logged in previously in the device, than he/she will not log in again. To Login again firstly Logout from Settings.
    
//    [self getSplashImages];
    
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
                
                RearMenuViewController *rearMenuViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
                self.revealController = [[SWRevealViewController alloc] initWithRearViewController:rearMenuViewController frontViewController:self.frontNavigationController];
                
                [self.window setRootViewController:self.revealController];

            }
            else
            {
                RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                recentChatViewController.isFromPush = YES;
                self.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
                
                RearMenuViewController *rearMenuViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
                [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
                [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
                
                self.revealController = [[SWRevealViewController alloc] initWithRearViewController:rearMenuViewController frontViewController:self.frontNavigationController];
                
                [self.window setRootViewController:self.revealController];
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSDictionary *messageDict = @{msg_text: serverNotif[@"aps"][@"alert"], msg_Date: serverNotif[@"aps"][msg_Date], msg_ID: serverNotif[@"aps"][msg_ID], msg_Reciver_ID: [FacebookUtility sharedObject].fbID, msg_Sender_ID: serverNotif[@"aps"][@"sFid"],msg_Sender_Name: serverNotif[@"aps"][msg_Sender_Name]};
                    [[ChatViewController sharedChatInstance] recieveMessage:serverNotif[@"aps"]];
                    [[ChatViewController sharedChatInstance] addMessageToDatabase:[Message messageWithDictionary:messageDict]];
                });
            }
            
            
        });
        
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"] length])
        {
            // Find Match
            
            FindMatchViewController *findMatchViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FindMatchViewController"];
            self.frontNavigationController = [[UINavigationController alloc] initWithRootViewController:findMatchViewController];
            [FacebookUtility sharedObject].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbID"];
            [FacebookUtility sharedObject].fbFullName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbFullName"];
            
            RearMenuViewController *rearMenuViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RearMenuViewController"];
            self.revealController = [[SWRevealViewController alloc] initWithRearViewController:rearMenuViewController frontViewController:appDelegate.frontNavigationController];
            
            [self.window setRootViewController:self.revealController];
            
        }
        else
        {
            // Login
            self.frontNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FirstNavigationController"];
            
            self.window.rootViewController = self.frontNavigationController;
        }
    }
    
    [self.window makeKeyAndVisible];
    
//    SplashView *splashView = [[SplashView alloc] initWithFrame:self.window.bounds];
//    
//    [self.window addSubview:splashView];
//    [self.window bringSubviewToFront:splashView];
//    [self setImagesOnWall:splashView];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(90 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [splashView removeFromSuperview];
//    });
//    
    
    return YES;
}

//- (void)setImagesOnWall:(SplashView *)splashView
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *basePath = [paths objectAtIndex:0];
//    
//    basePath = [basePath stringByAppendingPathComponent:@"Splash_Images"];
//    
//    for (int i = 0 ; i < 10; i++)
//    {
//        UIImageView *imageView = (UIImageView *)[splashView viewWithTag:i+1];
//        
//        NSString *filePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png",i+1]];
//        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
//        [imageView setImage:image];
//    }
//}

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
                            
                            NSString *filePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%u.png",[imageURLArray indexOfObject:dict]+1]];
                            
                            [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
                            
                            
                        }
                    }
                    
                    
                }];
            }
        }
        
        
    }];
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
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:@"1234" forKey:kDeviceToken];
//    [userDefaults synchronize];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Server Notification = %@",userInfo);
    
    UINavigationController *frontNavigationController = (id)self.revealController.frontViewController;
    [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
    
    if ([userInfo[@"aps"][@"nt"] isEqualToString:@"2"])
    {
         NSDictionary *messageDict = @{msg_text: userInfo[@"aps"][@"alert"], msg_Date: userInfo[@"aps"][msg_Date], msg_ID: userInfo[@"aps"][msg_ID], msg_Reciver_ID: [FacebookUtility sharedObject].fbID, msg_Sender_ID: userInfo[@"aps"][@"sFid"],msg_Sender_Name: userInfo[@"aps"][msg_Sender_Name]};
        if ([frontNavigationController.topViewController isKindOfClass:[ChatViewController class]])
        {
            ChatViewController *chatViewController = (ChatViewController *)frontNavigationController.topViewController;
            if ([chatViewController.recieveFBID isEqualToString:userInfo[@"aps"][@"sFid"]])
            {
                [chatViewController recieveMessage:userInfo[@"aps"]];
            }
           
            [chatViewController addMessageToDatabase:[Message messageWithDictionary:messageDict]];
        }
        else if (self.isAppinBackground)
        {
            self.isAppinBackground = NO;
            if ([frontNavigationController.topViewController isKindOfClass:[RecentChatsViewController class]])
            {
                [frontNavigationController pushViewController:[ChatViewController sharedChatInstance] animated:YES];
                if (self.revealController.frontViewPosition != 3)
                {
                    [self.revealController revealToggle:self];
                }
                
            }
            else
            {
                UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                RecentChatsViewController *recentChatViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"RecentChatsViewController"];
                frontNavigationController = [[UINavigationController alloc] initWithRootViewController:recentChatViewController];
                recentChatViewController.isFromPush = YES;
                [self.revealController pushFrontViewController:frontNavigationController animated:YES];
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
    else if ([userInfo[@"aps"][@"nt"] isEqualToString:@"2"])
    {
        
    }
    else
    {
        
        if ([frontNavigationController.topViewController isKindOfClass:[KeepingConnectingViewController class]])
        {
            if (self.revealController.frontViewPosition != 3)
            {
                [self.revealController revealToggle:self];
            }
            else
            {
                [Utils showOKAlertWithTitle:@"Dating" message:userInfo[@"aps"][@"alert"]];
            }
            
        }
        else
        {
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            KeepingConnectingViewController *keepConnectingViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"KeepingConnectingViewController"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:keepConnectingViewController];
            [self.revealController pushFrontViewController:navigationController animated:YES];
        }

    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSLog(@"Server Notification When Disabled = %@",userInfo);
    
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
