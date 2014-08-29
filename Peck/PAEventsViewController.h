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
#import "PANestedTableViewController.h"


@interface PAEventsViewController : PANestedTableViewController <NSFetchedResultsControllerDelegate, PACoreDataProtocol, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSFetchedResultsController *leftFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *centerFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *rightFetchedResultsController;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIImageView *placeholderImage;

@property (assign, nonatomic) NSInteger selectedDay;

@property (strong, nonatomic) NSCache *imageCache;
@property (nonatomic) CGFloat animationTime;

-(void)transitionToRightTableView;
-(void)transitionToLeftTableView;

-(void)switchToCurrentDay;
-(void)switchToPreviousDay;
-(void)switchToNextDay;
@end
