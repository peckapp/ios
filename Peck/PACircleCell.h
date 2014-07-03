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
@property (strong, nonatomic) IBOutlet PACircleScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *commentsTable;


@property(nonatomic, assign) id <PACirclesControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger members;
@property BOOL loadedImages;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


-(void)addImages:(NSArray*)members;
@end
