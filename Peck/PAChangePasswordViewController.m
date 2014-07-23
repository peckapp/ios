//
//  PAChangePasswordViewController.m
//  Peck
//
//  Created by John Karabinos on 7/18/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAChangePasswordViewController.h"
#import "PASyncManager.h"


@interface PAChangePasswordViewController ()

@end

@implementation PAChangePasswordViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.passwordField.delegate=self;
    self.oldPasswordField.delegate=self;
    self.confirmPasswordField.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

*/


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if (textField == self.oldPasswordField) {
        [self.passwordField becomeFirstResponder];
    }else if (textField == self.passwordField) {
        [self.confirmPasswordField becomeFirstResponder];
    }else if(textField == self.confirmPasswordField){
        [self.confirmPasswordField resignFirstResponder];
        return YES;
    }
    return NO;
}


- (IBAction)changePasswordButton:(id)sender {
    NSDictionary* newPassword = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.passwordField.text, @"password",
                                 self.confirmPasswordField.text, @"password_confirmation",
                                 nil];
    
    NSDictionary* passwordChange = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.oldPasswordField.text, @"password",
                                    newPassword, @"new_password",
                                    nil];
    [[PASyncManager globalSyncManager] changePassword:passwordChange];
    
}
@end
