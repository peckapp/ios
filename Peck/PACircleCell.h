//
//  PACircleCellTableViewCell.h
//  Peck
//
//  Created by John Karabinos on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACirclesTableViewController.h"
#import "Circle.h"

@interface PACircleCell : UITableViewCell <NSFetchedResultsControllerDelegate,
                                           UIGestureRecognizerDelegate,
                                           UITableViewDelegate,
                                           UITableViewDataSource,
                                           UITextFieldDelegate,
                                           UIActionSheetDelegate>

- (IBAction)leaveCircleButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *leaveCircleButton;
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)createCircleButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *createCircleButton;
@property (weak, nonatomic) IBOutlet UILabel *circleTitle;
@property (strong, nonatomic) UITableView *profilesTableView;

@property(nonatomic, assign) id <PACirclesControllerDelegate> delegate;
@property BOOL loadedImages;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) NSString* commentText;
@property (strong, nonatomic) NSMutableArray * suggestedMembers;

@property (strong, nonatomic) UITextField * textCapture;
@property (strong, nonatomic) UITextField * keyboardTextField;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (strong, nonatomic) Circle *circle;
@property (weak, nonatomic) UITableViewController *parentViewController;
@property BOOL addingMembers;

//-(void)addMember:(NSNumber *)member;
-(void)updateCircleMembers:(NSArray *)circleMembers;
-(void)performFetch;
-(void)expand:(PACommentCell*)cell;
-(void)compress:(PACommentCell*)cell;
@end
