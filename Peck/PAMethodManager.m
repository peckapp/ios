//
//  PAMethodManager.m
//  Peck
//
//  Created by John Karabinos on 8/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAMethodManager.h"
#import "PAAppDelegate.h"
#import "Peer.h"
#import "UIImageView+AFNetworking.h"
#import "PAAssetManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PAFetchManager.h"
#import "PASyncManager.h"
#import "PAUtils.h"
#import "PAChangePasswordViewController.h"

@interface PAMethodManager()

@property UIAlertView* registerAlert;
@property UIAlertView* institutionAlert;
@property UIAlertView* unauthorizedAlert;
@property UIAlertView* noInternetAlert;

@property (strong, nonatomic) void (^instCallbackBlock)(void);
@property (strong, nonatomic) void (^unauthCallbackBlock)(void);

@end

@implementation PAMethodManager



+ (instancetype)sharedMethodManager{
    
    static PAMethodManager *_sharedMethodManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMethodManager = [[PAMethodManager alloc] init];
        
        _sharedMethodManager.institutionAlert = [[UIAlertView alloc] initWithTitle:@"Foreign Institution"
                                                                           message:@"Your current institution will be switched to your home institution to complete this action"
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Cancel"
                                                                 otherButtonTitles:@"Continue", nil];
        _sharedMethodManager.unauthorizedAlert = [[UIAlertView alloc] initWithTitle:@"Unauthorized Action"
                                                                           message:@"Hmm, you seem to be improperly authenticated. Please login again."
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Okay"
                                                                 otherButtonTitles:nil];
    });
    
    return _sharedMethodManager;
}

#pragma mark - Alerts

-(void)showRegisterAlert:(NSString*)message forViewController:(UIViewController *)sender{
    /*Brings up a ui alert if an unregistered user attempts to perform an action reserved for registered users
    ACTIONS SO FAR:
        Posting an event
        Posting an announcement
        Posting a comment to an event (they will not be able to post to a circle because they will not have any)
        Attending an event
        Creating a circle
    */
    if (self.registerAlert == nil) {
        self.registerAlert = [[UIAlertView alloc] initWithTitle:@"Unregistered Account"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:@"Register", @"Login", nil];
    }
    message = [@"Please register or login to " stringByAppendingString:message];
    self.registerAlert.message = message;
    self.registerAlert.delegate = self;
    self.sender = sender;
    [self.registerAlert show];
}

-(void)showInstitutionAlert:(void (^)(void))callbackBlock{
    self.instCallbackBlock = callbackBlock;
    self.institutionAlert.delegate=self;
    [self.institutionAlert show];
}

-(void)showNoInternetAlertWithMessage:(NSString*)message {
    if (self.noInternetAlert == nil) {
        self.noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Connection Lost"
                                                          message:@"msg"
                                                         delegate:self
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
    }
    if (message) {
        self.noInternetAlert.message = message;
    } else {
        self.noInternetAlert.message = @"Please connect to the internet to complete this operation";
    }
    [self.noInternetAlert show];
}

-(void)showUnauthorizedAlertWithCallbackBlock:(void (^)(void))callbackBlock {
    self.unauthCallbackBlock = callbackBlock;
    self.unauthorizedAlert.delegate=self;
    [self.unauthorizedAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Registration/Login Alert
    if(alertView==self.registerAlert){
        if(buttonIndex==1){
            //The user has selected register
            UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            UIViewController *registerController = [loginStoryboard instantiateViewControllerWithIdentifier:@"register"];
            [self.sender presentViewController:registerController animated:YES completion:nil];
        } else if (buttonIndex==2) {
            UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            UIViewController *loginController = [loginStoryboard instantiateInitialViewController];
            [self.sender presentViewController:loginController animated:YES completion:nil];
        }
        self.registerAlert = nil;
    }
    // Institution Alert
    else if(alertView==self.institutionAlert){
        if(buttonIndex==1){
            //The user has pressed continue. We must switch to the user's home institution and then call the call back block to continue the action
            NSLog(@"switch the institution");
            [[PAFetchManager sharedFetchManager] manuallyChangeInstituion];
            if (self.instCallbackBlock != nil) {
                self.instCallbackBlock();
            }
        }else{
            NSLog(@"don't perform the action");
        }
    }
    // Unauthorized Alert
    else if(alertView==self.unauthorizedAlert){
        switch (buttonIndex) {
            case 0: {
                //The user is already logged out and has pressed okay.
                //We must switch to the user's home institution and then execute the callback
                NSLog(@"presenting login process");
                PAAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
                [appDel.dropDownBar selectItemAtIndex:4];
                
                PAProfileTableViewController* profileController = appDel.profileViewController;
                [appDel.profileViewController.navigationController popToRootViewControllerAnimated:NO];
                // must be presented by the dropdownController to ensure that it appears above the dropdown bar
                [profileController presentLoginStoryboardFromViewController:appDel.dropdownController];
                
                if (self.unauthCallbackBlock != nil) {
                    self.unauthCallbackBlock();
                }
            }
                break;
            case 1:
                // since this shouldn't ever really happen, could do a link to support/feedback page
                NSLog(@"presenting support view");
                break;
                
            default:
                NSLog(@"not a current case");
                break;
        }
    }
}

#pragma mark - Other

-(BOOL)serverIsReachable {
    // TODO: attempt connection with the server
    return YES;
}

-(UIImageView*)imageForPeer:(Peer*)peer{
    if (peer.imageURL) {
        NSURL* imageURL = [NSURL URLWithString:peer.imageURL];
        UIImage* image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
        if(image){
            return [[UIImageView alloc] initWithImage:image];
        }
        else {
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:imageURL placeholderImage:[[PAAssetManager sharedManager] profilePlaceholder]];
            return imageView;
        }
    }
    else {
        return [[UIImageView alloc] initWithImage:[[PAAssetManager sharedManager] profilePlaceholder]];
    }

}

-(void)postInfoToFacebook:(NSDictionary*)eventInfo withImage:(NSData*)imageData{
    //NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:[eventInfo objectForKey:@"image"]]];
    //UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    UIImage* img = [UIImage imageWithData:imageData];
    if(img){
        [FBRequestConnection startForUploadStagingResourceWithImage:img completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error) {
                NSArray* imageArray = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
                [self continuePost:imageArray withDictionary:eventInfo];
            } else {
                // An error occurred
                
                NSLog(@"Error staging an image: %@", error);
            }
        }];
        
    }else{
        [self continuePost:nil withDictionary:eventInfo];
    }
}


-(void)continuePost:(NSArray*)imageArray withDictionary:(NSDictionary*)eventInfo{
    // Log the uri of the staged image
   /// NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
    
    // Further code to post the OG story goes here
    
    
    // instantiate a Facebook Open Graph object
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    
    // specify that this Open Graph object will be posted to Facebook
    object.provisionedForPost = YES;
    
    // for og:title
    object[@"title"] = [eventInfo objectForKey:@"title"]; ;
    
    // for og:type, this corresponds to the Namespace you've set for your app and the object type name
    object[@"type"] = @"com_peckapp_peck:event";
    
    // for og:description
    object[@"description"] =[eventInfo objectForKey:@"event_description"] ;
    
    // for og:url, we cover how this is used in the "Deep Linking" section below
    object[@"url"] =[ @"http://loki.peckapp.com:3500/deep_links/native_peck?event_id=" stringByAppendingString:[[eventInfo objectForKey:@"id"] stringValue]];
    //object[@"url"] = @"http://example.com/roasted_pumpkin_seeds";
    //TODO: fix the url to work with deep linking
    
    // for og:image we assign the image that we just staged, using the uri we got as a response
    // the image has to be packed in a dictionary like this:
    //object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
    if(imageArray){
        object[@"image"] = imageArray;
    }
    //object[@"event_id"] = [[eventInfo objectForKey:@"id"] stringValue];
    
    
    // Create an action
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
    
    // Link the object to the action
    [action setObject:object forKey:@"event"];
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBOpenGraphActionParams *params = [[FBOpenGraphActionParams alloc] init];
    params.action = action;
    params.actionType = @"com_peckapp_peck:event";
    
    // If the Facebook app is installed and we can present the share dialog
    if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
        // Show the share dialog
        [FBDialogs presentShareDialogWithOpenGraphAction:action
                                              actionType:@"com_peckapp_peck:post"
                                     previewPropertyName:@"event"
                                                 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                     if(error) {
                                                         // There was an error
                                                         NSLog(@"Error publishing story: %@", error.description);
                                                     } else {
                                                         // Success
                                                         NSLog(@"result %@", results);
                                                     }
                                                 }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK GOES HERE
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [eventInfo objectForKey:@"title"], @"name",
                                       [eventInfo objectForKey:@"event_description"], @"description",
                                       [ @"http://loki.peckapp.com:3500/deep_links/native_peck?event_id=" stringByAppendingString:[[eventInfo objectForKey:@"id"] stringValue]], @"link",
                                        nil];
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Error launching the dialog or publishing a story.
                                                         // NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                           
                                                          }
                                                      }
                                                  }];
        
    }
    

}

-(void)handleResetLink:(NSMutableDictionary*)urlInfo{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"authentication_token"]){
        //if the user has clicked a confirmation link and is currently signed in
        [self logoutUserCompletely];
        
        if (FBSession.activeSession.state == FBSessionStateOpen|| FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
        }
    }
    //At this point the user is certainly logged out, and we may continue by sending the email and password to api/access
    
    NSDictionary* loginInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               [urlInfo objectForKey:@"email"],@"email",
                               [urlInfo objectForKey:@"temp_pass"], @"password",
                               storedPushToken, @"device_token",
                               nil];
    
    NSLog(@"login info %@", loginInfo);
    [[PASyncManager globalSyncManager] authenticateUserWithInfo:loginInfo withCallbackBlock:^(BOOL success){
        if (success) {
            PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
            UIViewController* currentController = [appdelegate topMostController];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navController = [mainStoryboard instantiateViewControllerWithIdentifier:@"changePasswordController"];
            PAChangePasswordViewController* root = navController.viewControllers[0];
            root.tempPass =[loginInfo objectForKey:@"password"];
            
            [currentController presentViewController:navController animated:YES completion:nil];
        }
    }];
}

- (void)logoutUserCompletely {
    [[PASyncManager globalSyncManager] logoutUser];
    
    [[PAFetchManager sharedFetchManager] logoutUser];
    
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"authentication_token"];
    [defaults removeObjectForKey:@"first_name"];
    [defaults removeObjectForKey:@"last_name"];
    [defaults removeObjectForKey:@"blurb"];
    [defaults removeObjectForKey:@"email"];
    [defaults removeObjectForKey:@"profile_picture_url"];
    [defaults removeObjectForKey:@"facebook_profile_picture_url"];
    [defaults removeObjectForKey:@"home_institution"];
    
    [defaults setObject:@NO forKey:@"logged_in"];
    
    [[PASyncManager globalSyncManager] ceateAnonymousUser:nil];
}

#pragma mark - Tutorial

// sets the nsuserdefaults boolean values to false for each tutorial
-(void)resetTutorialBooleans {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@YES forKey:homepage_tutorial];
    [defaults setObject:@YES forKey:dropdown_tutorial];
    [defaults setObject:@YES forKey:post_tutorial];
    [defaults setObject:@YES forKey:attend_tutorial];
}

-(void)showTutorialAlertWithTitle:(NSString *)title andMessage:(NSString*)message {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles:nil];
    [alert show];
}

@end
