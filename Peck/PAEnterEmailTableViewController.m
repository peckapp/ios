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

@interface PAEnterEmailTableViewController ()

@end

@implementation PAEnterEmailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        self.emailField.placeholder = [@"example" stringByAppendingString:currentInstitution.email_regex];
    }
    
}

- (IBAction)finishLogin:(id)sender {
    if([self emailMatchesInstitution:self.emailField.text]){
        [self.parent loginWithFacebook:self.parent.user andBool:YES withEmail:self.emailField.text];
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


@end
