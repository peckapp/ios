//
//  PAEvents.h
//  Peck
//
//  Created by John Karabinos on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PAEventBST.h"

@interface PAEvents : NSObject <NSFetchedResultsControllerDelegate>
+(instancetype)events;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (atomic, retain) PAEventBST * eventTree;
@end