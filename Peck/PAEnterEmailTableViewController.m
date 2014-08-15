//
//  PAEnterEmailTableViewController.m
//  Peck
//
//  Created by John Karabinos on 8/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAEnterEmailTableViewController.h"
#import "PAInitialViewController.h"
#import "Institution.h"
#import "PAFetchManager.h"
#import "PASyncManager.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PAEnterEmailTableViewController ()

@end

@implementation PAEnterEmailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailField.delegate=self;
    self.passwordField.delegate=self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                    message:@"The email account registered with your Facebook account does not match the institution you have selected"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    Institution* currentInstitution = [[PAFetchManager sharedFetchManager] fetchInstitutionForID:[[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"]];

    
    if(currentInstitution.email_regex){
        self.emailField.placeholder = [@"email" stringByAppendingString:currentInstitution.email_regex];
    }else{
        self.emailField.placeholder = @"email@yourInstitution.edu";
    }
    
    self.passwordCell.hidden = YES;
    self.resetPasswordCell.hidden = YES;
}

- (IBAction)finishLogin:(id)sender {
    [self finishTheLogin];
}

-(void)finishTheLogin{
    if([self emailMatchesInstitution:self.emailField.text]){
        if(self.passwordCell.hidden){
            [self.parent loginWithFacebook:self.parent.user andBool:YES withEmail:self.emailField.text withCallback:^(BOOL emailNotFound){
                if(emailNotFound){
                    //The user has entered an email that does not match any emails in the database
                    if (FBSession.activeSession.state == FBSessionStateOpen|| FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
                        
                        // Close the session and remove the access token from the cache
                        // The session state handler (in the app delegate) will be called automatically
                        [FBSession.activeSession closeAndClearTokenInformation];
                    }
                }else{
                    //The user has entered an email that already exists. We will ask the user for the password of the existing account.
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Existing Account"
                                                                    message:@"The email you have entered matches the email of an existing user. Please enter the password of the account to link it with Facebook."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    [self addPasswordFields];
                    
                }
            }];
        }else{
            //the user is attempting to login with a password to an already existing account
            FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
            NSString* token = [accessTokenData accessToken];
            
            NSDictionary* loginInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       self.emailField.text,@"email",
                                       self.passwordField.text, @"password",
                                       @"6c6cfc215bdc2d7eeb93ac4581bc48f7eb30e641f7d8648451f4b1d3d1cde464", @"device_token",
                                       [self.parent.user objectForKey:@"link"], @"facebook_link",
                                       token, @"facebook_token",
                                       
                                       nil];
            [[PASyncManager globalSyncManager] authenticateUserWithInfo:loginInfo forViewController:self direction:NO];
        }
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                        message:@"The email does not match the current institution"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)backButton:(id)sender {
    if (FBSession.activeSession.state == FBSessionStateOpen|| FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }

    [self.navigationController popViewControllerAnimated:YES];
    
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


-(void)addPasswordFields{
    self.passwordCell.hidden=NO;
    self.resetPasswordCell.hidden=NO;
    self.emailField.returnKeyType = UIReturnKeyNext;
}

- (IBAction)forgotPasswordButton:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset Password?"
                                                    message:@"Are you sure you want to reset your password? A confirmation email will be sent to the email you have provided."
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        //reset the user's password
        NSDictionary* dictionary = [NSDictionary dictionaryWithObject:self.emailField.text forKey:@"email"];
        [[PASyncManager globalSyncManager] resetPassword:dictionary];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==self.emailField && self.passwordCell.hidden==YES){
        //if the user is entering the email and has not been prompted for a password
        [self finishTheLogin];
        [textField resignFirstResponder];
        return YES;
    }else if(textField==self.emailField && self.passwordCell.hidden == NO){
        [self.passwordField becomeFirstResponder];
        return NO;
    }else{
        //the password field
        [self finishTheLogin];
        [textField resignFirstResponder];
        return YES;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

@end
