//
//  PADiningCell.h
//  Peck
//
//  Created by John Karabinos on 7/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "DiningPlace.h"

@interface PADiningCell : UITableViewCell <UITableViewDataSource,UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;

@property (weak, nonatomic) IBOutlet UITableView *menuItemsTableView;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) DiningPlace *diningPlace;
@property (strong, nonatomic) Event* diningOpportunity;

-(void)performFetch;
@end


