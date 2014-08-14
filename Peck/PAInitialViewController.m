//
//  PeckInitialViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PAInitialViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PASyncManager.h"
#import "PAFetchManager.h"
#import "Institution.h"
#import "PAEnterEmailTableViewController.h"

@interface PAInitialViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet FBLoginView *fbLogin;

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
    self.fbLogin.readPermissions = @[@"public_profile", @"email", @"user_friends", @"publish_actions"];
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
        [self finishLogin:self];
    }
    
    return NO;
}

# pragma mark - Navigation

- (IBAction)cancelLogin:(id)sender
{
    [self dismissKeyboard];
    // dismiss the current login process to return to the main app
    if(self.justOpenedApp){
        [[PASyncManager globalSyncManager] createAnonymousUserHelper];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishLogin:(id)sender {
    NSLog(@"finish the login");
    if(![self.emailField.text isEqualToString:@""] && ![self.passwordField.text isEqualToString:@""]){
        NSDictionary* loginInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.emailField.text,@"email",
                                   self.passwordField.text, @"password",
                                   @"6c6cfc215bdc2d7eeb93ac4581bc48f7eb30e641f7d8648451f4b1d3d1cde464", @"device_token",
                                   nil];
        [[PASyncManager globalSyncManager] authenticateUserWithInfo:loginInfo forViewController:self direction:self.justOpenedApp];
    }
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    // TODO: need to perform appropriate handling of the user here, including sending the necessary information back to the server
    
    if ([self verifyFacebookLoginWithUser:user]) {
       
        NSLog(@"user info: %@ %@ %@ %@", [user objectForKey:@"first_name"], [user objectForKey:@"last_name"], [user objectForKey:@"email"], [[FBSession activeSession] accessTokenData]);
        
        
        
        BOOL sendEmail = YES;
        if([self emailMatchesInstitution:[user objectForKey:@"email"]]){
            //The email matches the institution that the user has chosen. In this case, we will simply perform a normal login through facebook
            sendEmail = NO;
            [self loginWithFacebook:user andBool:NO withEmail:[user objectForKey:@"email"]];
        }else{
            //The email does not match the institution that the user has chosen. In this case we must call the method in the sync manager that checks to see if a facebook link already exists for the user.
            NSDictionary* dictionary = [NSDictionary dictionaryWithObject:[user objectForKey:@"link"] forKey:@"facebook_link"];
            [[PASyncManager globalSyncManager] checkFacebookUser:dictionary withCallback:^(BOOL registered, NSString* email){
                if(registered){
                    NSLog(@"continue with normal facebook login");
                    [self loginWithFacebook:user andBool:NO withEmail:email];
                }else{
                    NSLog(@"ask the user for his institution email");
                    self.user = user;
                    [self performSegueWithIdentifier:@"enterValidEmail" sender:self];
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

-(void)loginWithFacebook:(id<FBGraphUser>)user andBool:(BOOL)sendEmail withEmail:(NSString*)email{
    
    FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
    NSString* token = [accessTokenData accessToken];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [user objectForKey:@"first_name"],@"first_name",
                              [user objectForKey:@"last_name"],@"last_name",
                              email,@"email",
                              token, @"facebook_token",
                              @"6c6cfc215bdc2d7eeb93ac4581bc48f7eb30e641f7d8648451f4b1d3d1cde464", @"device_token",
                              [[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"],@"institution_id",
                              [NSNumber numberWithBool:sendEmail], @"send_email",
                              [user objectForKey:@"link"], @"facebook_link",
                              nil];
    
    //We will store the picture locally that facebook has given us in case the user has not saved a new photo
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectID]];
    
    [[NSUserDefaults standardUserDefaults] setObject:userImageURL forKey:@"profile_picture_url"];
    
    [[PASyncManager globalSyncManager] loginWithFacebook:userInfo forViewController:self];
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
        //PAEnterEmailTableViewController* destintation = [segue destinationViewController];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect email or password"
                                                    message:@"Please enter a valid email and password"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
