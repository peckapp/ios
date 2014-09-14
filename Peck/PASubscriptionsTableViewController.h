//
//  PASubscriptionsTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PASubscriptionsTableViewController : UITableViewController <PACoreDataProtocol, NSFetchedResultsControllerDelegate>

//@property (strong, nonatomic) NSMutableArray* departmentSubscriptions;
//@property (strong, nonatomic) NSMutableArray* clubSubscriptions;
//@property (strong, nonatomic) NSMutableArray* athleticSubscriptions;

@property (strong, nonatomic) NSMutableDictionary* addedSubscriptions;
@property (strong, nonatomic) NSMutableDictionary* deletedSubscriptions;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property BOOL isInitializing;

@end
