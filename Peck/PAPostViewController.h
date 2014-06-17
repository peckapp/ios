//
//  PAPostViewController.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PAPostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PACoreDataProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (IBAction)segmentedControl:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *controlSwitch;

- (IBAction)okayButton:(id)sender;

@property (strong, nonatomic) NSArray *eventItems;
@property (strong, nonatomic) NSArray *eventSuggestions;
@property (strong, nonatomic) UIImage *photo;

@property (strong, nonatomic) NSMutableArray *userEvents;

@end
