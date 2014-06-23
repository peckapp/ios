//
//  PAMasterViewController.h
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "PACoreDataProtocol.h"

@interface PAEventsViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (IBAction)yesterdayButton:(id)sender;
- (IBAction)todayButton:(id)sender;
- (IBAction)tomorrowButton:(id)sender;
@end
