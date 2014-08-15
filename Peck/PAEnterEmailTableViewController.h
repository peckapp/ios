//
//  PAEnterEmailTableViewController.h
//  Peck
//
//  Created by John Karabinos on 8/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAInitialViewController.h"

@interface PAEnterEmailTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)finishLogin:(id)sender;
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) PAInitialViewController* parent;
- (IBAction)forgotPasswordButton:(id)sender;

@property (weak, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *resetPasswordCell;

@end
