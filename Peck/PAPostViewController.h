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

- (IBAction)segmentedControl:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *controlSwitch;

- (IBAction)cancelButton:(id)sender;
@property (strong, nonatomic) NSArray *eventItems;
@property (strong, nonatomic) NSArray *eventSuggestions;
@property (strong, nonatomic) UIImage *photo;

@property (strong, nonatomic) NSMutableArray *userEvents;
@property (strong, nonatomic) NSMutableArray *userMessages;
@property (strong, nonatomic) NSMutableArray *userPhotos;

@end
