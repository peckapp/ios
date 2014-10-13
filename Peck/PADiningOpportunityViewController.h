//
//  PADiningOpportunityViewController.h
//  Peck
//
//  Created by Jonas Luebbers on 8/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
#import "PANestedTableViewCell.h"
#import "PACommentCell.h"
#import "DiningPlace.h"
#import "Event.h"
#import "PADiningPlacesTableViewController.h"

@interface PADiningOpportunityViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PANestedCellControllerProtocol>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) DiningPlace *detailItem;
@property (strong, nonatomic) Event* diningOpportunity;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) PADiningPlacesTableViewController* parentController;

@end
