//
//  PASubscriptionsCollectionViewController.h
//  Peck
//
//  Created by Aaron Taylor on 9/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PASubscriptionsCollectionViewController : UICollectionViewController <PACoreDataProtocol, NSFetchedResultsControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

// accessed by the cells when they are modified to keep track of changes to be sent to the webservice
@property (strong, nonatomic) NSMutableDictionary* addedSubscriptions;
@property (strong, nonatomic) NSMutableDictionary* deletedSubscriptions;

// fetched results controller to keep data accurate
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// whether this is instantiated in the initial install process or within the settings tab.
@property BOOL isInitializing;

@end
