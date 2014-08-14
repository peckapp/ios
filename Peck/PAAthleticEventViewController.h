//
//  PAAthleticEventViewController.h
//  Peck
//
//  Created by Jonas Luebbers on 8/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
#import "PANestedTableViewCell.h"
#import "PACommentCell.h"


@interface PAAthleticEventViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PANestedTableViewCellSubviewControllerProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) id detailItem;
- (IBAction)attendButton:(id)sender;

@property (strong, nonatomic) NSString* commentText;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAttendees;
@property (weak, nonatomic) IBOutlet UIButton *attendButton;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIImage* userPicture;

- (void)expandTableViewCell:(PACommentCell *)cell;
- (void)compressTableViewCell:(PACommentCell *)cell;
- (void)postComment:(NSString *)text;
- (void)configureView;
@end