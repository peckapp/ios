//
//  PeckInitialViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PAInitialViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PAInitialViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet FBLoginView *fbLogin;

- (IBAction)cancelLogin:(id)sender;

@end

@implementation PAInitialViewController

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
    
    self.emailField.placeholder = @"email@yourinstitution.edu";
    self.passwordField.placeholder = @"password";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    /*
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 375);
    loginView.delegate=self;
    [self.view addSubview:loginView];
     */
    
    self.fbLogin.delegate = self;
    NSLog(@"fbLogin height: %f",self.fbLogin.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self.passwordField resignFirstResponder];
        // performs the login segue as though the button was pressed
        if ([self shouldPerformSegueWithIdentifier:@"register" sender:self]) {
            [self performSegueWithIdentifier:@"register" sender:self];
        }
    }
    
    return NO;
}

# pragma mark - Navigation

- (IBAction)cancelLogin:(id)sender
{
    [self dismissKeyboard];
    // dismiss the current login process to return to the main app
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    // TODO: need to perform appropriate handling of the user here, including sending the necessary information back to the server
    
    if ([self verifyFacebookLoginWithUser:user]) {
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self performSegueWithIdentifier:@"login" sender:self];
            
        });
    }
    
    
    
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"register"]) {
        // attempt login authentication with the server, if it succeeds, skip registration, otherwise continue as normal
        if ([self correctLogin]) {
            // no need to register, already has an account
            [self performSegueWithIdentifier:@"login" sender:self];
            return NO;
        } else {
            return YES;
        }
        
    } else if ([identifier isEqualToString:@"login"]) {
        return YES;
    } else {
        // no other segues exist to be performed from this view controller
        return NO;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

# pragma mark - Network Calls

- (BOOL)correctLogin
{
    // TODO: merely for testing purposes, should interact with server to verify login
    if ([self.emailField.text isEqualToString:@"test"]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)verifyFacebookLoginWithUser:(id<FBGraphUser>)user
{
    return YES;
}

# pragma mark - utilities

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
