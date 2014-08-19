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
#import "PAMethodManager.h"
#import "PAAssetManager.h"


@implementation PAAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


-(void)setProfileProperty:(PAProfileTableViewController*)profileController{
    self.profileViewController = profileController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // uncomment during application launch to clear out all NSUserDefaults
    // [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    
    // uncomment at launch to delete persistant store. probably a very messy way to do it
    /*
    for (NSPersistentStore *pstore in [[self persistentStoreCoordinator] persistentStores]) {
        [[self persistentStoreCoordinator] removePersistentStore:pstore error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@",pstore.URL] error:nil];
    }
     */
    
    
    // Override point for customization after application launch.
    
    //NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //[UICKeyChainStore setString:deviceId forKey:@"deviceId" service:@"Devices"];
    
    // register to observe notifications from the store
    [[NSNotificationCenter defaultCenter]addObserver: self
                                            selector: @selector (iCloudKeyStateChanged:)
                                                name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                              object: [NSUbiquitousKeyValueStore defaultStore]];
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          //[self sessionStateChanged:session state:state error:error];
                                      }];
    }
    // get changes that might have happened while this
    // instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    NSString* udid = [store objectForKey:@"udid"];
    NSLog(@"sync? %i",[[NSUbiquitousKeyValueStore defaultStore] synchronize]);
    if(udid == nil){
        NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [store setObject:deviceId forKey:@"udid"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
    NSLog(@"MY UDID: %@", [store objectForKey:@"udid"]);
    
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

    self.window.tintColor = [[PAAssetManager sharedManager] lightColor];

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
    //[Crashlytics startWithAPIKey:@"147270e58be36f1b12187f08c0fa5ff034e701c8"];
    
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    return YES;
}

#pragma facebook stuff

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        //[self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //[self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                //[self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //[self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

#pragma mark - Notifications

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Device Token ---> %@", token);
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    [[PASyncManager globalSyncManager] updatePecks];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"did receive local notification: %@",notification);
}

#pragma mark - iCloud

- (void)iCloudKeyStateChanged:(NSNotification*)notification {
    
}

#pragma mark - Facebook API

// In order to process the response you get from interacting with the Facebook login process
// and to handle any deep linking calls from Facebook
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        if([[call appLinkData] targetURL] != nil) {
            // get the object ID string from the deep link URL
            // we use the substringFromIndex so that we can delete the leading '/' from the targetURL
            NSString *objectId = [[[call appLinkData] targetURL].path substringFromIndex:1];
            NSDictionary* queryData = call.appLinkData.originalQueryParameters;
            
            NSLog(@"the url of the object: %@", [[call appLinkData] targetURL]);
            
            // now handle the deep link
            // write whatever code you need to show a view controller that displays the object, etc.
            [[[UIAlertView alloc] initWithTitle:@"Directed from Facebook"
                                        message:[NSString stringWithFormat:@"Deep link to %@", objectId]
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
        } else {
            //
            NSLog(@"Unhandled deep link: %@", [[call appLinkData] targetURL]);
        }
    }];
    
    
    NSLog(@"incoming url: %@", url);
    NSMutableDictionary* urlInfo = [self urlToDictionary:[url absoluteString]];
    if(urlInfo){
        if([[urlInfo objectForKey:@"view"] isEqualToString:@"passwordReset"]){
            [[PAMethodManager sharedMethodManager] handleResetLink:urlInfo];
        }
    }
    
    
    return wasHandled;
}

-(NSMutableDictionary*)urlToDictionary:(NSString*)url{
    NSMutableDictionary* queryDictionary = [[NSMutableDictionary alloc] init];
    
    //sets the url to everything after the question mark
    NSArray* urlArray =[url componentsSeparatedByString:@"?"];
    if([urlArray count]>1){
        url = urlArray[1];
        NSArray* urlComponents = [url componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [queryDictionary setObject:value forKey:key];
        }
        return queryDictionary;
    }else{
        return nil;
    }
    
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
    @synchronized(self) {
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
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    @synchronized(self) {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Peck" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
    }
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized(self) {
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
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
