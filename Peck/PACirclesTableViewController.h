//
//  PACirclesTableViewController.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PACoreDataProtocol.h"
#import "Peer.h"
@class PACommentCell;

@protocol PACirclesControllerDelegate <UITableViewDelegate>

- (void)profile:(int) member withCircle:(NSInteger)circle;
- (void)promptToAddMemberToCircleCell:(UITableViewCell *)cell;

@end

@interface PACirclesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDelegate, UITableViewDataSource, PACirclesControllerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * circles;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)dismissCommentKeyboard;
-(void)postComment:(PACommentCell*)cell;
-(void)showProfileOf:(Peer*)member;
-(void)expandTableViewCell:(PACommentCell *)cell;
-(void)compressTableViewCell:(PACommentCell *)cell;
- (void)dismissKeyboard:(id)sender;
-(void)addMember:(Peer*)newMember;
@end

