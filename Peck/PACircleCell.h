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
#import "Circle.h"

@interface PACircleCell : UITableViewCell <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *circleTitle;
@property (weak, nonatomic) IBOutlet UITableView *profilesTableView;

@property(nonatomic, assign) id <PACirclesControllerDelegate> delegate;
@property BOOL loadedImages;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) NSString* commentText;

@property (strong, nonatomic) UITextField * textCapture;
@property (strong, nonatomic) UITextField * keyboardTextField;

@property (strong, nonatomic) Circle *circle;
@property (weak, nonatomic) UITableViewController *parentViewController;

-(void)addMember:(NSNumber *)member;
-(void)updateCircleMembers:(NSArray *)circleMembers;
-(void)performFetch;
-(void)expand:(PACommentCell*)cell;
-(void)compress:(PACommentCell*)cell;
@end
