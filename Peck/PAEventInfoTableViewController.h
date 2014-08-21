//
//  PAEventInfoTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//
//  This view controller displays the event information (start time, end time, description etc.), as well as comments.
//  The view calls a get request to reload the comments every couple of seconds while active.

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
#import "PANestedTableViewCell.h"

@class PACommentCell;

@interface PAEventInfoTableViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PANestedTableViewCellSubviewControllerProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) NSString* commentText;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIImage* userPicture;

- (void)expandTableViewCell:(PACommentCell *)cell;
- (void)compressTableViewCell:(PACommentCell *)cell;
- (void)postComment:(NSString *)text;
- (void)configureView;
@end
