//
//  AFMasterViewController.h
//  UICollectionViewExample
//
//  Created by Ash Furrow on 2012-09-11.
//  Copyright (c) 2012 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PACoreDataProtocol.h"

@interface PASubscriptionsSelectorVC : UICollectionViewController <PACoreDataProtocol, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// whether this is instantiated in the initial install process or within the settings tab.
@property BOOL isInitializing;

@end
