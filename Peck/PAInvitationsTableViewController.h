//
//  PAInvitationsTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/18/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PAInvitationsDelegate

@required

- (void)didInvitePeople:(NSMutableDictionary *)people andCircles:(NSMutableDictionary *)circles;

@end

@interface PAInvitationsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) id<PAInvitationsDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray* suggestedInvites;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSMutableDictionary* invitedPeople;
@property (strong, nonatomic) NSMutableDictionary* invitedCircles;
@property (weak, nonatomic) NSArray* invitedPeopleArray;
@property (weak, nonatomic) NSArray* invitedCirclesArray;

- (IBAction)addInvites:(id)sender;
- (IBAction)cancel:(id)sender;

@end
