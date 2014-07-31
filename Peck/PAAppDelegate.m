//
//  PAAppDelegate.m
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAAppDelegate.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Crashlytics/Crashlytics.h>

#import "PAEventsViewController.h"
#import "PACoreDataProtocol.h"
#import "PAConfigureViewController.h"
#import "PADropdownViewController.h"
#import "PASyncManager.h"
#import <Security/Security.h>



@implementation PAAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // uncomment during application launch to clear out all NSUserDefaults
    // [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    
    // Override point for customization after application launch.
    
    //NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //[UICKeyChainStore setString:deviceId forKey:@"deviceId" service:@"Devices"];
    
    UIViewController *initViewController;
    _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // institutional ID initialization
    NSNumber *institutionID = [defaults objectForKey:@"institution_id"];
    NSLog(@"INSTITUTION ID: %@", institutionID);
    
    // user ID initialization
    NSNumber * userID = [defaults objectForKey:@"user_id"];
    NSLog(@"USER ID: %@", userID);
    
    if(institutionID == nil){
        NSLog(@"Open up the configure screen");
        initViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"configure"];
        
        if(userID == nil){
            /*
            [[PASyncManager globalSyncManager] ceateAnonymousUser:^(BOOL success) {
                if (success) {
                    NSLog(@"Sucessfully set a new anonymous user");
                    PAConfigureViewController* configure = (PAConfigureViewController*) initViewController;
                    [configure updateInstitutions];
                } else {
                    NSLog(@"Anonymous user creation unsucessful");
                }
            }];*/
            [[PASyncManager globalSyncManager] sendUDIDForInitViewController:initViewController];
        }
    }
    // this is the device-specific identifier that we should be worrying about to keep track of things per-device
    NSLog(@"ID for vendor: %@",[UIDevice currentDevice].identifierForVendor);
    
    // if the user has already registered for push notifications allowing us to send them push notifications
    // this relies upon the token being in NSUserDefaults and the user having registered ALWAYS happening at the same time, which may not actually be true... requires further thought
    NSNumber *loggedIn = [defaults objectForKey:@"logged_in"];
    if (loggedIn && [loggedIn isEqualToNumber:@YES]) {
        NSLog(@"registering device for push notifications on launch");
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
    // handles notifications that were queued while the app was closed
    NSDictionary *remoteNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification != nil) {
        NSLog(@"launched with remote notification: %@",remoteNotification);
        // handle push notifications received while application was in background
    }
    UILocalNotification *localNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification != nil) {
        NSLog(@"launched with local notification: %@",localNotification);
    }

    self.window.tintColor = [UIColor colorWithRed:150/255.0 green:123/255.0 blue:255/255.0 alpha:1.0];

    // saves NSUserDefaults to "disk"
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // initializes the singleton
    [FBLoginView class];
    
    if (initViewController == nil) {
        initViewController = [self.mainStoryboard instantiateInitialViewController];
    }
    [self.window setRootViewController:initViewController];
    
    
    // TODO: remove this line with the next release of the new relic monitoring software. it quiets the threading logs
    [NRLogger setLogLevels:NRLogLevelNone];
    // activates connection to New Relic monitoring software
    [NewRelicAgent startWithApplicationToken:@"AA14f069ef90609bd31c564006eebc0c133696af3b"];
    
    // Must remain after third-party SDK code
    [Crashlytics startWithAPIKey:@"147270e58be36f1b12187f08c0fa5ff034e701c8"];
    
    
    return YES;
}


#pragma mark - Notifications

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Device Token ---> %@", token);
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[PASyncManager globalSyncManager] sendUserDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"we have a problem %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"while running did receive remote notification: %@",userInfo);
    } else if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"while in background did receive remote notification: %@",userInfo);
    } else {
        NSLog(@"while in unknown state did receive remote notification: %@",userInfo);
    }
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"did receive remote notification: %@ with fetch completion handler",userInfo);
    
    // handle all types of notifications here and call completion handler with the proper UIBackgroundFetchResult for each case
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"did receive local notification: %@",notification);
}

#pragma mark - Facebook API

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {


    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];

    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

#pragma mark - Standard methods

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    // for testing purposes
    //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"institution_id"];
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Peck" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Peck.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
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
        // TODO: eliminate this call
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
