//
//  PeckInitialViewController.h
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PAUtils.h"

@interface PAInitialViewController : UITableViewController <FBLoginViewDelegate, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

-(void)showAlert;
@property NSString* direction;
@property PAViewControllerMode mode;
@property (strong ,nonatomic) id<FBGraphUser> user;
- (IBAction)resetPassword:(id)sender;

-(void)loginWithFacebook:(id<FBGraphUser>)user andBool:(BOOL)sendEmail withEmail:(NSString*)email withCallback:(void(^)(BOOL))callbackBlock;

@end
