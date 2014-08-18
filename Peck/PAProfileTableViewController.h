//
//  PAProfileTableViewController2.h
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PAProfileTableViewController : UITableViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITextFieldDelegate>{
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *registerButton;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UITextField *facebookTextField;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property (strong, nonatomic) NSString* tempPass;
- (IBAction)saveChangesButton:(id)sender;
@end
