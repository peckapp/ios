//
//  PAAppDelegate.h
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PADropdownBar.h"
#import "PACirclesTableViewController.h"

@interface PAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, weak) UIStoryboard * mainStoryboard;

@property (strong, nonatomic) PADropdownBar* dropDownBar;
@property (strong, nonatomic) PACirclesTableViewController* circleViewController;

// icloud triggered selector for remote change to key-value store
- (void)iCloudKeyStateChanged:(NSNotification*)notification;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
