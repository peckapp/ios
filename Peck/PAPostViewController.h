//
//  PAPostViewController.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
#import "Event.h"
#import "Announcement.h"

@interface PAPostViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PACoreDataProtocol, UITextViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (IBAction)returnResultAndExit:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *topRightBarButton;

@property (weak, nonatomic) NSString* controllerStatus;
@property (weak, nonatomic) Event* editableEvent;
@property (weak, nonatomic) Announcement* editableAnnouncement;

@property (weak, nonatomic) IBOutlet UIImageView *photo;

@property (weak, nonatomic) IBOutlet UISegmentedControl *controlSwitch;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endTimeCell;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *startTimePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endTimePickerCell;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *inviteCell;
@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *selectorCell;

@property (strong, nonatomic) NSMutableArray *userEvents;
@property (strong, nonatomic) NSArray* invitedPeople;
@property (strong, nonatomic) NSArray* invitedCircles;

@property (strong, nonatomic) NSMutableDictionary* invitedPeopleDictionary;
@property (strong, nonatomic) NSMutableDictionary* invitedCirclesDictionary;

@property (strong, nonatomic) NSDateFormatter* formatter;

@end
