//
//  PADiningPlacesTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
#import "DiningPeriod.h"
#import "DiningPlace.h"
#import "PANestedTableViewCell.h"

@interface PADiningPlacesTableViewController : UITableViewController <PACoreDataProtocol, PANestedTableViewCellSubviewControllerProtocol>

@property (weak, nonatomic) IBOutlet UILabel *mealLabel;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)configureView;
- (void)fetchDiningPlace:(DiningPeriod*)diningPeriod;
- (void)addDiningPlace:(DiningPlace*) diningPlace withPeriod:(DiningPeriod*)diningPeriod;
- (void)setManagedObject:(NSManagedObject *)managedObject;

@end
