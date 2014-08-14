//
//  PAEnterEmailTableViewController.h
//  Peck
//
//  Created by John Karabinos on 8/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAEnterEmailTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *emailField;
- (IBAction)finishLogin:(id)sender;
- (IBAction)backButton:(id)sender;

@end
