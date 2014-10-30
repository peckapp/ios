//
//  PeckInitialViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PAInitialViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PAAppDelegate.h"
#import "PASyncManager.h"
#import "PAFetchManager.h"
#import "Institution.h"
#import "PAEnterEmailTableViewController.h"
#import "PAUtils.h"
#import "PAMethodManager.h"

@interface PAInitialViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet FBLoginView *fbLogin;
@property (strong, nonatomic) UIAlertView* resetPassAlert;

@property (strong, nonatomic) UIAlertView* switchInstAlert;
@property (strong, nonatomic) UIAlertView* invalidEmailAlert;

- (IBAction)cancelLogin:(id)sender;
- (IBAction)finishLogin:(id)sender;


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
    
    Institution* currentInstitution = [[PAFetchManager sharedFetchManager] fetchInstitutionForID:[[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"]];
    if(currentInstitution.email_regex){
        self.emailField.placeholder = [@"email" stringByAppendingString:currentInstitution.email_regex];
    }else{
        self.emailField.placeholder = @"email@yourInstitution.edu";
    }
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
    self.fbLogin.readPermissions = @[@"public_profile", @"email", @"user_friends"];//, @"publish_actions"];
    NSLog(@"fbLogin height: %f",self.fbLogin.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView setUserInteractionEnabled:YES];
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
        [self finishLogin:self];
    }
    
    return NO;
}

# pragma mark - Navigation

- (IBAction)cancelLogin:(id)sender
{
    [self dismissKeyboard];
    // dismiss the current login process to return to the main app
    if([self.direction isEqualToString:@"homepage"]){
        [[PASyncManager globalSyncManager] createAnonymousUserHelper];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Peck Login

- (IBAction)finishLogin:(id)sender {
    NSLog(@"finish the login");
    if(![self.emailField.text isEqualToString:@""] && ![self.passwordField.text isEqualToString:@""]){
        NSDictionary* loginInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.emailField.text,@"email",
                                   self.passwordField.text, @"password",
                                   storedPushToken, @"device_token",
                                   nil];
        
        void (^callbackBlock)(BOOL);
        if (self.mode == PAViewControllerModeInitializing) {
            callbackBlock = ^(BOOL success) {
                PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
                [appDelegate.window setRootViewController:newRoot];
            };
        } else {
            callbackBlock = ^(BOOL success) {
                [self dismissViewControllerAnimated:YES completion:^() {
                    [self.view setUserInteractionEnabled:YES];
                }];
            };
        }
        
        [[PASyncManager globalSyncManager] authenticateUserWithInfo:loginInfo withCallbackBlock:callbackBlock];
    } else {
        [[PAMethodManager sharedMethodManager] showTutorialAlertWithTitle:@"Missing Login Info" andMessage:@"Please enter a username and password"];
    }
}

- (IBAction)resetPassword:(id)sender {
    self.resetPassAlert = [[UIAlertView alloc] initWithTitle:@"Reset Password?"
                                                     message:@"Are you sure you want to reset your password? A confirmation email will be sent to the email you have provided."
                                                    delegate:self
                                           cancelButtonTitle:@"No"
                                           otherButtonTitles:@"Yes", nil];
    [self.resetPassAlert show];
    
}

#pragma mark - Facebook Login

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    // TODO: need to perform appropriate handling of the user here, including sending the necessary information back to the server
    
    if ([self verifyFacebookLoginWithUser:user]) {
        
        NSLog(@"user info: %@ %@ %@ %@", [user objectForKey:@"first_name"], [user objectForKey:@"last_name"], [user objectForKey:@"email"], [[FBSession activeSession] accessTokenData]);
        
        REGISTER_PUSH_NOTIFICATIONS;
        
        //BOOL sendEmail = YES;
        if([self emailMatchesCurrentInstitution:[user objectForKey:@"email"]]){
            //The email matches the institution that the user has chosen. In this case, we will simply perform a normal login through facebook
            //sendEmail = NO;
            [self loginWithFacebook:user andBool:NO withEmail:[user objectForKey:@"email"] withCallback:nil];
        }else{
            //The email does not match the institution that the user has chosen. In this case we must call the method in the sync manager that checks to see if a facebook link already exists for the user.
            NSDictionary* dictionary = [NSDictionary dictionaryWithObject:[user objectForKey:@"link"] forKey:@"facebook_link"];
            [[PASyncManager globalSyncManager] checkFacebookUser:dictionary withCallback:^(BOOL registered, NSString* email){
                if(registered){
                    NSLog(@"continue with normal facebook login");
                    [self loginWithFacebook:user andBool:NO withEmail:email withCallback:nil];
                }else{
                    NSLog(@"ask the user for his institution email");
                    self.user = user;
                    Institution *inst = [[PAFetchManager sharedFetchManager] fetchInstitutionMatchingEmail:[user objectForKey:@"email"]];
                    if (inst != nil) {
                        NSString *msg = [NSString stringWithFormat:@"The email registered with your Facebook account does not match your currently selected institution, but does match %@. Would you like to switch?",inst.name];
                        if (self.switchInstAlert == nil) {
                            self.switchInstAlert = [[UIAlertView alloc] initWithTitle:@"Unmatched Email"
                                                                              message:msg
                                                                             delegate:self
                                                                    cancelButtonTitle:@"No"
                                                                    otherButtonTitles:@"Switch", nil];
                        }
                        [self.switchInstAlert show];
                    } else {
                        if (self.invalidEmailAlert == nil) {
                            self.invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                                                message:@"The email registered with your Facebook account does not match any available institution."
                                                                               delegate:self
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles: nil];
                        }
                        [self.invalidEmailAlert show];
                    }
                }
            }];
        }
        
        /*
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self performSegueWithIdentifier:@"login" sender:self];
            
        });*/
        
    }
}

// if the facebook information is appropriate, attempt to authenticate with our servers
-(void)loginWithFacebook:(id<FBGraphUser>)user andBool:(BOOL)sendEmail withEmail:(NSString*)email withCallback:(void(^)(BOOL))callbackBlock {
    
    FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
    NSString* fbToken = [accessTokenData accessToken];
    NSString* instID = [[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"];
    NSString* deviceToken = storedPushToken;
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [user objectForKey:@"first_name"],@"first_name",
                              [user objectForKey:@"last_name"],@"last_name",
                              email,@"email",
                              fbToken, @"facebook_token",
                              instID,@"institution_id",
                              @"ios",@"device_type",
                              [NSNumber numberWithBool:sendEmail], @"send_email",
                              [user objectForKey:@"link"], @"facebook_link",
                              deviceToken, @"device_token",
                              nil];
    
    NSLog(@"facebook user dictionary %@", userInfo);
    
    //We will store the picture locally that facebook has given us in case the user has not saved a new photo
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectID]];
    
    [[NSUserDefaults standardUserDefaults] setObject:userImageURL forKey:@"facebook_profile_picture_url"];
    
    [self.tableView setUserInteractionEnabled:NO];
    
    void (^newCallback)(BOOL);
    if (self.mode == PAViewControllerModeInitializing) {
        newCallback = ^(BOOL success) {
            if (callbackBlock) {
                callbackBlock(success);
            }
            PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
            [appDelegate.window setRootViewController:newRoot];
        };
    } else {
        newCallback = ^(BOOL success) {
            if (callbackBlock) {
                callbackBlock(success);
            }
            [self dismissViewControllerAnimated:YES completion:^() {
                [self.view setUserInteractionEnabled:YES];
            }];
        };
    }
    
    
    [[PASyncManager globalSyncManager] loginWithFacebook:userInfo withCallback:newCallback];
}

#pragma mark - UIAlertViewDelegate


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.switchInstAlert) {
        if (buttonIndex == 1) {
            // if desired by the user, the institution id is updated to that matching their facebook email account
            Institution *inst = [[PAFetchManager sharedFetchManager] fetchInstitutionMatchingEmail:[self.user objectForKey:@"email"]];
            [[NSUserDefaults standardUserDefaults] setObject:inst.id forKey:institution_id_key];
            [self loginWithFacebook:self.user andBool:NO withEmail:[self.user objectForKey:@"email"] withCallback:nil];
        } else {
            // is the user does not want the institution matching their email for some reason, it continues to the email enter page
            [self performSegueWithIdentifier:@"enterValidEmail" sender:self];
        }
    } else if (alertView == self.invalidEmailAlert) {
        [self performSegueWithIdentifier:@"enterValidEmail" sender:self];
    }
    else if(buttonIndex==1 && alertView==self.resetPassAlert){
        //reset the user's password
        NSDictionary* dictionary = [NSDictionary dictionaryWithObject:self.emailField.text forKey:@"email"];
        [[PASyncManager globalSyncManager] resetPassword:dictionary];
    }
}

#pragma mark - Navigation

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
    if([[segue identifier] isEqualToString:@"enterValidEmail"]){
        PAEnterEmailTableViewController* destintation = [segue destinationViewController];
        destintation.parent = self;
    }
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
    if (FBSession.activeSession.state == FBSessionStateOpen) {
        return YES;
    }else{
        return NO;
    }
}

# pragma mark - utilities

-(BOOL)emailMatchesCurrentInstitution:(NSString*)userEmail{
    Institution* currentInstitution = [[PAFetchManager sharedFetchManager] fetchInstitutionForID:[[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"]];
    NSString* emailExtension = currentInstitution.email_regex;
    //NSString* userEmail = [user objectForKey:@"email"];
    NSInteger preceedingLength = [userEmail length] - [emailExtension length];
    if(preceedingLength>0) {
        NSString* userEmailExtension = [userEmail substringFromIndex:preceedingLength];
        if([userEmailExtension isEqualToString:emailExtension]){
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
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

-(void)showAlert{
    NSLog(@"wrong information");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                    message:@"Please enter a valid email and password"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
