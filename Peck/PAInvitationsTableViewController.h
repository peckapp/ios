//
//  PAInvitationsTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/18/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAInvitationsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray* suggestedInvites;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//@property (strong, nonatomic) NSMutableArray* invitedPeople;
@property (strong, nonatomic) NSMutableDictionary* invitedPeople;
@property (strong, nonatomic) NSMutableDictionary* invitedCircles;

@property (weak, nonatomic) IBOutlet UITableView *invitedPeopleTableView;
@property (strong, nonatomic) UIViewController* parentPostViewController;
- (IBAction)addInvites:(id)sender;
@end
