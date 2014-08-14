//
//  PeckInitialViewController.h
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface PAInitialViewController : UITableViewController <FBLoginViewDelegate, UITableViewDelegate, UITextFieldDelegate>
-(void)showAlert;
@property BOOL justOpenedApp;
@property id<FBGraphUser> user;
-(void)loginWithFacebook:(id<FBGraphUser>)user andBool:(BOOL)sendEmail withEmail:(NSString*)email;
@end
