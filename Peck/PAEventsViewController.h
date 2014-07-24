//
//  PAMasterViewController.h
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//
//  This view controller displays the homepage of the user, where all events that the user is subscribed to will appear.
//  Selecting an event will push the PAEventsInfoViewController, which will display more detail about the event

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "PACoreDataProtocol.h"

@interface PAEventsViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UITableView * tableView;

@property (strong, nonatomic) NSCache* imageCache;
- (IBAction)yesterdayButton:(id)sender;
- (IBAction)todayButton:(id)sender;
- (IBAction)tomorrowButton:(id)sender;

-(void)cacheImages;
@end
