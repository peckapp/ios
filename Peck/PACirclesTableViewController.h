//
//  PACirclesTableViewController.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PACoreDataProtocol.h"

@protocol PACirclesControllerDelegate <UITableViewDelegate>

-(void)Profile:(int) userID;

@end

@interface PACirclesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDelegate, UITableViewDataSource, PACirclesControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray * tempCircles;

@end

