//
//  PASubscriptionsCollectionViewController.h
//  Peck
//
//  Created by Aaron Taylor on 9/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PASubscriptionsCollectionViewController : UICollectionViewController <PACoreDataProtocol, NSFetchedResultsControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property BOOL isInitializing;

@end
