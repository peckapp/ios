//
//  PAPecksViewController.h
//  Peck
//
//  Created by Jonas Luebbers on 6/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PACoreDataProtocol.h"


@interface PAPecksViewController : UITableViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *items;

@end
