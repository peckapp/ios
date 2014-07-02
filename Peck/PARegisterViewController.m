//
//  PeckRegisterViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/15/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PARegisterViewController.h"

@interface PARegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextView *blurbTextView;

@property (weak, nonatomic) IBOutlet UITableViewCell *facebookCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *instagramCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *twitterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *googleCell;

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
    } else if (textField == self.lastNameField) {
        [self.blurbTextView becomeFirstResponder];
        // performs the login segue as though the button was pressed
        if ([self shouldPerformSegueWithIdentifier:@"register" sender:self]) {
            [self performSegueWithIdentifier:@"register" sender:self];
        }
    } else {
        [self.blurbTextView resignFirstResponder];
        
        if ([self shouldPerformSegueWithIdentifier:@"finish" sender:self]) {
            [self performSegueWithIdentifier:@"finish" sender:self];
        }
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
    // send current information to the server and check result
    return YES;
}

- (void)dismissKeyboard
{
    // dismisses the keyboard
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self dismissKeyboard];
}

@end
