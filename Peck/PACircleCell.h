//
//  PACircleCellTableViewCell.h
//  Peck
//
//  Created by John Karabinos on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACirclesTableViewController.h"
#import "PACircleScrollView.h"

@interface PACircleCell : UITableViewCell <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *circleTitle;
@property (weak, nonatomic) IBOutlet UITableView *profilesTableView;

@property(nonatomic, assign) id <PACirclesControllerDelegate> delegate;
@property BOOL loadedImages;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) NSMutableArray *members;

-(void)updateCircleMembers:(NSArray *)circleMembers;
@end
