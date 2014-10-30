//
//  ConfigureViewController.h
//  Peck
//
//  Created by John Karabinos on 6/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
#import "PAUtils.h"

@interface PAConfigureViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, PACoreDataProtocol>

@property (nonatomic) PAViewControllerMode mode;

- (IBAction)continueButton:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) IBOutlet UIPickerView *schoolPicker;

-(void)updateInstitutions;

@end
