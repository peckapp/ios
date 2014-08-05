//
//  PAUserEventsTableViewController.h
//  Peck
//
//  Created by John Karabinos on 8/5/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PAUserEventsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol>


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
