//
//  PeckRegisterViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/15/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PARegisterViewController.h"
#import "PASyncManager.h"
#import "PAFetchManager.h"
#import "PAUtils.h"

@interface PARegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextView *blurbTextView;
@property (weak, nonatomic) IBOutlet UITextField *passwordField1;
@property (weak, nonatomic) IBOutlet UITextField *passwordField2;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UITableViewCell *facebookCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *instagramCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *twitterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *googleCell;
- (IBAction)cancelButton:(id)sender;

@end


@implementation PARegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.firstNameField.placeholder = @"John";
    self.lastNameField.placeholder = @"Doe";
    self.blurbTextView.text = @"";
    self.passwordField1.delegate=self;
    self.passwordField2.delegate=self;
    self.emailField.delegate=self;
    
    Institution* currentInstitution = [[PAFetchManager sharedFetchManager] fetchInstitutionForID:[[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"]];
    if(currentInstitution.email_regex){
        self.emailField.placeholder = [@"email" stringByAppendingString:currentInstitution.email_regex];
    }else{
        self.emailField.placeholder = @"email@yourInstitution.edu";
    }
    self.passwordField1.placeholder = @"********";
    self.passwordField2.placeholder = @"********";
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard
{
    [self.view endEditing:NO];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    // the
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

# pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    
    if (textField == self.firstNameField) {
        [self.lastNameField becomeFirstResponder];
        NSLog(@"next");
    }
    else if (textField == self.lastNameField) {
        [self.passwordField1 becomeFirstResponder];
    }
    else if(textField == self.passwordField1){
        [self.passwordField2 becomeFirstResponder];
    }
    else if (textField == self.passwordField2){
        [self.emailField becomeFirstResponder];
    }
    else if(textField == self.emailField){
        [self.blurbTextView becomeFirstResponder];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    return NO;
}

    
#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"finish"]) {
        // send registration information the server, if it suceeds continue, otherwise display error
        
        return [self attemptRegistration];
    }
    // no other segues exist to be performed from this view controller
    return NO;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

# pragma mark - utilities

- (BOOL)attemptRegistration
{
    if(![self.passwordField2.text isEqualToString:@""] && ![self.passwordField1.text isEqualToString:@""] && ![self.firstNameField.text isEqualToString:@""] && ![self.lastNameField.text isEqualToString:@""] && ![self.emailField.text isEqualToString:@""]){
    
        if([self.passwordField1.text isEqualToString:self.passwordField2.text]){
        
            if([self emailMatchesInstitution:self.emailField.text]){
            
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSNumber * institutionID = [defaults objectForKey:@"institution_id"];
                NSNumber * userID = [defaults objectForKey:@"user_id"];
        
                NSDictionary *registeredUser = [NSDictionary dictionaryWithObjectsAndKeys:
                                                self.firstNameField.text, @"first_name",
                                                self.lastNameField.text, @"last_name",
                                                self.passwordField1.text, @"password",
                                                self.passwordField2.text, @"password_confirmation",
                                                self.blurbTextView.text, @"blurb",
                                                self.emailField.text, @"email",
                                                institutionID, @"institution_id",
                                                userID, @"id",
                                                @"ios", @"device_type",
                                                storedPushToken, @"device_token",
                                                nil];
        
                [[PASyncManager globalSyncManager] registerUserWithInfo:registeredUser forViewController:self];
                // send current information to the server and check result
                //return YES;
                //we don't want to go to that scary loading sceen
                return NO;
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                                message:@"Your email does not match the institution you have selected"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

                
                return NO;
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Different Passwords"
                                                            message:@"Your passwords must match"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

            return NO;
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                        message:@"Required fields are blank"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        
        return NO;
    }
    
}

-(BOOL)emailMatchesInstitution:(NSString*)userEmail{
    Institution* currentInstitution = [[PAFetchManager sharedFetchManager] fetchInstitutionForID:[[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"]];
    NSString* emailExtension = currentInstitution.email_regex;
    //NSString* userEmail = [user objectForKey:@"email"];
    NSInteger preceedingLength = [userEmail length] - [emailExtension length];
    if(preceedingLength>0){
        NSString* userEmailExtension = [userEmail substringFromIndex:preceedingLength];
        if([userEmailExtension isEqualToString:emailExtension]){
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

- (void)dismissKeyboard
{
    // dismisses the keyboard
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self dismissKeyboard];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"selected the path");
}

- (IBAction)cancelButton:(id)sender {
    [self dismissKeyboard];
    // dismiss the current login process to return to the main app
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
