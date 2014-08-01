//
//  PASyncManager.m
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASyncManager.h"

#import "webservice.h"

#import "PAAppDelegate.h"
#import "Event.h"
#import "Circle.h"
#import "PASessionManager.h"
#import "Peer.h"
#import "Explore.h"
#import "Institution.h"
#import "Comment.h"
#import "PACirclesTableViewController.h"
#import "DiningPlace.h"
#import "PADiningPlacesTableViewController.h"
#import "DiningPeriod.h"
#import "MenuItem.h"
#import "PACircleCell.h"
#import "PAInitialViewController.h"
#import "PAChangePasswordViewController.h"
#import "Subscription.h"
#import "PAFetchManager.h"
#import "PAEventsViewController.h"
#import "PAEventInfoTableViewController.h"
#import "PAConfigureViewController.h"
#import "Peck.h"

#define serverDateFormat @"yyyy-MM-dd'T'kk:mm:ss.SSS'Z'"
#define shortTermUDID @"1"

@interface PASyncManager ()

- (NSDictionary*) addUDIDToDictionary:(NSDictionary*)dictionary;

@property (weak, nonatomic) UIViewController* initialViewController;

@end

@implementation PASyncManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;


+ (instancetype)globalSyncManager {
    static PASyncManager *_globalSyncManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalSyncManager = [[PASyncManager alloc] init];
    });
    
    return _globalSyncManager;
}

#pragma mark - User actions

-(void)sendUserDeviceToken:(NSString*)deviceToken{
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                deviceToken, @"token",
                                shortTermUDID, @"udid",
                                //[store objectForKey:@"udid"],@"udid",
                                nil];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* deviceTokenURL = [@"api/users/" stringByAppendingString:[[defaults objectForKey:@"user_id"] stringValue]];
    deviceTokenURL = [deviceTokenURL stringByAppendingString:@"/create_device_token"];
    NSLog(@"device token dictionary: %@", dictionary);
    [[PASessionManager sharedClient] PATCH:deviceTokenURL
                               parameters:[self applyWrapper:@"user_device_token" toDictionary:dictionary]
                                  success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                      NSLog(@"Device Token JSON: %@", JSON);
                                  }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                      
                                  }];


    
}

-(void)sendUDIDForInitViewController:(UIViewController*)initViewController{
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                //[store objectForKey:@"udid"],@"udid",
                                shortTermUDID,@"udid",
                                nil];
    [[PASessionManager sharedClient] POST:@"api/users/user_for_udid"
                               parameters:dictionary
                                  success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                      self.initialViewController = initViewController;
                                      NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                                      NSDictionary* userDictionary = (NSDictionary*)JSON;
                                      NSDictionary* userAttributes = [userDictionary objectForKey:@"user"];
                                      NSLog(@"USER ATTRIBUTES DICTIONARY: %@", userAttributes);
                                      if([[userAttributes objectForKey:@"new_user"] boolValue]==YES){
                                          // if there was not a user previously on this device
                                          NSNumber *userID = [userAttributes objectForKey:@"id"];
                                          [defaults setObject:userID forKey:user_id];
                                          NSString *apiKey = [userAttributes objectForKey:api_key];
                                          [defaults setObject:apiKey forKey:api_key];
                                          PAConfigureViewController* configure = (PAConfigureViewController*) self.initialViewController;
                                          [configure updateInstitutions];
                                      }else{
                                          // if there was a user previously on this device (registered or not registered)
                                          
                                          if(![[userAttributes objectForKey:@"first_name"] isKindOfClass:[NSNull class]]){
                                              //if the user was registered
                                              [defaults setObject:[userAttributes objectForKey:@"api_key"] forKey:@"api_key"];
                                              [defaults setObject:[userAttributes objectForKey:@"user_id"] forKey:@"user_id"];
                                              NSString* message = [@"Would you like to use " stringByAppendingString:[userAttributes objectForKey:@"first_name"]];
                                              message = [message stringByAppendingString:@"'s information?"];
                                              UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Logged In User Exists"
                                                                                                  message:message
                                                                                                 delegate:self
                                                                                        cancelButtonTitle:@"No"
                                                                                        otherButtonTitles:@"Yes",nil];
                                              [loginAlert show];
                                          }
                                          else{
                                              //if the user was not registered
                                              //we will load the user id and api key into user defaults because they will be overwritten if the user chooses not to load the previous user's info
                                              
                                              NSNumber *userID = [userAttributes objectForKey:@"id"];
                                              [defaults setObject:userID forKey:user_id];
                                              NSString *apiKey = [userAttributes objectForKey:api_key];
                                              NSLog(@"API KEY: %@", [userAttributes objectForKey:api_key]);
                                              [defaults setObject:apiKey forKey:api_key];
                                              if(![[userAttributes objectForKey:@"institution_id"] isKindOfClass:[NSNull class]]){
                                                  [defaults setObject:[userAttributes objectForKey:@"institution_id"] forKey:@"institution_id"];
                                              }
                                              else{
                                                  [defaults setObject:[NSNumber numberWithInt:1] forKey:@"institution_id"];
                                              }
                                              UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"User Exists"
                                                                                         message:@"Would you like to use the previous user's information?"
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"No"
                                                                               otherButtonTitles:@"Yes",nil];
                                              [alert show];
                                          }
                                          //[self ceateAnonymousUser:callbackBlock];
                                      }
                                  }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"User Exists"]){
        //if there was an anonymous user last logged in on this device
        if (buttonIndex == 0){
            //If the user presses no, we will create an anonymous user and load the institutions
            NSLog(@"create a new user");
            [self createAnonymousUserHelper];
        }else{
            //If the user presses yes, we will load the previous data and segue to the homepage
            //Note that we have already added the necessary information into user defaults
            NSLog(@"use previous user info");
            PAConfigureViewController* configure = (PAConfigureViewController*) self.initialViewController;
            PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            // if this is root because of the initial download of the app
            if ([appDelegate window].rootViewController == configure) {
                UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
                NSLog(@"about to set the root");
                [appDelegate.window setRootViewController:newRoot];
            }
        }
    }else{
        if(buttonIndex==0){
            NSLog(@"create a new user");
            [self createAnonymousUserHelper];
        }else{
            NSLog(@"login the user");
            UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            UINavigationController *loginRoot = [loginStoryboard instantiateInitialViewController];
            PAInitialViewController* root = loginRoot.viewControllers[0];
            root.justOpenedApp=YES;
            [self.initialViewController presentViewController:loginRoot animated:YES completion:nil];
            //segue to the login page
        }
    }
}

-(void)createAnonymousUserHelper{
    [self ceateAnonymousUser:^(BOOL success) {
        if (success) {
            NSLog(@"Sucessfully set a new anonymous user");
            PAConfigureViewController* configure = (PAConfigureViewController*) self.initialViewController;
            [configure updateInstitutions];
        } else {
            NSLog(@"Anonymous user creation unsucessful");
        }
    }];
    PAConfigureViewController* configure = (PAConfigureViewController*) self.initialViewController;
    [configure updateInstitutions];
}

-(void)ceateAnonymousUser:(void (^)(BOOL))callbackBlock
{
    NSLog(@"creating an anonymous new user");
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSDictionary *deviceInfo = [NSDictionary dictionaryWithObject:[store objectForKey:@"udid"] forKey:@"udid"];
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObject:shortTermUDID forKey:@"udid"];
    NSLog(@"deviceInfo: %@", deviceInfo);
    [[PASessionManager sharedClient] POST:usersAPI
                               parameters:deviceInfo
                                  success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                      // response JSON contains a user_id and api_key that must be stored
                                      NSLog(@"Anonymous user creation success: %@", JSON);
                                      NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                      NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                      
                                      //store new information from server response
                                      NSNumber *userID = [userDictionary objectForKey:@"id"];
                                      [defaults setObject:userID forKey:user_id];
                                      NSString *apiKey = [userDictionary objectForKey:api_key];
                                      [defaults setObject:apiKey forKey:api_key];
                                      
                                      callbackBlock(YES);
                                  }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                      callbackBlock(NO);
                                  }];
}

-(void)updateUserWithInfo:(NSDictionary *)userInfo withImage:(NSData*)imageData
{
    NSString* updateURL = [usersAPI stringByAppendingString:@"/"];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* userID = [defaults objectForKey:@"user_id"];
    updateURL = [updateURL stringByAppendingString:[userID stringValue]];
    
    [self addUDIDToDictionary:userInfo];
    
    NSMutableDictionary* baseDictionary = [[self applyWrapper:@"user" toDictionary:userInfo] mutableCopy];
    [baseDictionary setObject:@"patch" forKey:@"_method"];
    
    NSDate* now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    NSInteger seconds = (NSInteger)nowEpochSeconds;
    
    NSString* fileName = [@"event_photo_" stringByAppendingString:[[defaults objectForKey:@"user_id" ] stringValue]];
    fileName = [fileName stringByAppendingString:@"_"];
    fileName = [fileName stringByAppendingString:[@(seconds) stringValue]];
    fileName = [fileName stringByAppendingString:@".jpeg"];
    //NSLog(@"file name %@", fileName);
    
    [[PASessionManager sharedClient] POST:updateURL
                                parameters: baseDictionary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];}
                                    success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                        // extract core dictionary from json
                                        NSLog(@"Update user success: %@", JSON);
                                        NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                        NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                        NSString* email = [userDictionary objectForKey:@"email"];
                                        NSString* blurb = [userDictionary objectForKey:@"blurb"];
                                        NSString* firstName = [userDictionary objectForKey:first_name_define];
                                        NSString* lastName = [userDictionary objectForKey:last_name_define];
                                        NSString* imageURL = [userDictionary objectForKey:@"image"];
                                        
                                        [defaults setObject:email forKey:@"email"];
                                        [defaults setObject:blurb forKey:@"blurb"];
                                        [defaults setObject:firstName forKey:first_name_define];
                                        [defaults setObject:lastName forKey:last_name_define];
                                        if(imageURL){
                                            UIImage* profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:imageURL]]]];
                                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                                 NSUserDomainMask, YES);
                                            NSString *documentsDirectory = [paths objectAtIndex:0];
                                            NSString* path = [documentsDirectory stringByAppendingPathComponent:
                                                              @"profile_picture.jpeg" ];
                                            NSData* data = UIImageJPEGRepresentation(profilePicture, .5);
                                            [data writeToFile:path atomically:YES];
                                            NSLog(@"path: %@", path);
                                            [defaults setObject:path forKey:@"profile_picture"];
                                        }
                                        
                                      }
                                      failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                          NSLog(@"ERROR: %@",error);
                                      }];
    
}

- (void)authenticateUserWithInfo:(NSDictionary*)userInfo forViewController:(UITableViewController*)controller
{
    // adds the unique user device token to the userInfo NSDictionary
    NSDictionary* userInfoWithUDID = [self addUDIDToDictionary:userInfo];
    
    // sends either email and password, or facebook token and link, to the server for authentication
    // expects an authentication token to be returned in response
    NSLog(@"Login dictionary: %@", userInfo);
    
    [[PASessionManager sharedClient] POST: @"api/access"
                               parameters:[self applyWrapper:@"user" toDictionary:userInfoWithUDID]
                                  success:^(NSURLSessionDataTask * __unused task, id JSON){
                                      NSLog(@"LOGIN JSON: %@",JSON);
                                      
                                      [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
                                      
                                      NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                      NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                      NSString* firstName = [userDictionary objectForKey:first_name_define];
                                      NSString* lastName = [userDictionary objectForKey:last_name_define];
                                      NSString* email = [userDictionary objectForKey:@"email"];
                                      NSString* blurb = [userDictionary objectForKey:@"blurb"];
                                      NSNumber* userID = [userDictionary objectForKey:@"id"];
                                      NSString* apiKey = [userDictionary objectForKey:@"api_key"];
                                      NSString* imageURL = [userDictionary objectForKey:@"image"];
                                      
                                      NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

                                      
                                      [defaults setObject:firstName forKey:first_name_define];
                                      [defaults setObject:lastName forKey:last_name_define];
                                      [defaults setObject:email forKey:@"email"];
                                      [defaults setObject:userID forKey:@"user_id"];
                                      [defaults setObject:apiKey forKey:@"api_key"];
                                      
                                      if(imageURL){
                                          NSLog(@"shared client base url: %@",[PASessionManager sharedClient].baseURL);
                                          UIImage* profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:imageURL]]]];
                                          NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                               NSUserDomainMask, YES);
                                          NSString *documentsDirectory = [paths objectAtIndex:0];
                                          NSString* path = [documentsDirectory stringByAppendingPathComponent:
                                                            @"profile_picture.jpeg" ];
                                          NSData* data = UIImageJPEGRepresentation(profilePicture, .5);
                                          [data writeToFile:path atomically:YES];
                                          NSLog(@"path: %@", path);
                                          [defaults setObject:path forKey:@"profile_picture"];
                                      }
                                      
                                      if(![blurb isKindOfClass:[NSNull class]]){
                                          [defaults setObject:blurb forKey:@"blurb"];
                                      }
                                      [defaults setObject:[userDictionary objectForKey:@"authentication_token"] forKey:auth_token];
                                      //update the subscriptions of the newly logged in user
                                      [self updateSubscriptions];
                                      
                                      //take care of some necessary login stuff
                                      [[PAFetchManager sharedFetchManager] loginUser];
                                      
                                      [controller dismissViewControllerAnimated:YES completion:nil];
                                  }
     
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                      PAInitialViewController* sender = (PAInitialViewController*)controller;
                                      [sender showAlert];
                                      
                                  }];

}

-(void)registerUserWithInfo:(NSDictionary*)userInfo{
    NSString* registerURL = [usersAPI stringByAppendingString:@"/"];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* userID = [defaults objectForKey:@"user_id"];
    registerURL = [registerURL stringByAppendingString:[userID stringValue]];
    registerURL = [registerURL stringByAppendingString:@"/super_create"];
    [[PASessionManager sharedClient] PATCH:registerURL
                               parameters:[self applyWrapper:@"user" toDictionary:userInfo]
                                  success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                      
                                      [defaults setObject:@YES forKey:@"logged_in"];
                                      [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
                                      
                                      //NSLog(@"user register success: %@", JSON);
                                      NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                      NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                      NSString* firstName = [userDictionary objectForKey:first_name_define];
                                      NSString* lastName = [userDictionary objectForKey:last_name_define];
                                      NSString* email = [userDictionary objectForKey:@"email"];
                                      NSString* blurb = [userDictionary objectForKey:@"blurb"];
                                      [defaults setObject:firstName forKey:first_name_define];
                                      [defaults setObject:lastName forKey:last_name_define];
                                      [defaults setObject:email forKey:@"email"];
                                      if(![blurb isKindOfClass:[NSNull class]]){
                                          [defaults setObject:blurb forKey:@"blurb"];
                                      }
                                      [defaults setObject:[userDictionary objectForKey:@"authentication_token"] forKey:auth_token];
                                  }
     
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
}


-(void)changePassword:(NSDictionary*)passwordInfo forViewController:(UIViewController*)controller{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* passwordURL = [usersAPI stringByAppendingString:@"/"];
    passwordURL = [passwordURL stringByAppendingString:[[defaults objectForKey:@"user_id"] stringValue]];
    passwordURL = [passwordURL stringByAppendingString:@"/change_password"];
    //NSLog(@"passwordURL: %@", passwordURL);
    
    [[PASessionManager sharedClient] PATCH:passwordURL
                                parameters:[self applyWrapper:@"user" toDictionary:passwordInfo]
                                   success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                       //NSLog(@"password JSON: %@",JSON);
                                       NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                       NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                       if([[userDictionary objectForKey:@"response"] isEqualToString:@"Old password was wrong"]){
                                           NSLog(@"show alert");
                                           PAChangePasswordViewController* sender = (PAChangePasswordViewController*)controller;
                                           [sender showWrongPasswordAlert];
                                       }else if([[userDictionary objectForKey:@"response"] isEqualToString:@"password was successfully changed!"]){
                                           PAChangePasswordViewController* sender = (PAChangePasswordViewController*)controller;
                                           [sender showSuccessAlert];
                                       }
                                   }
     
     
                                   failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                       NSLog(@"ERROR: %@",error);
                                   }];
}
- (BOOL)validUserInfo:(NSDictionary*)userInfo
{
    // TODO: check the user info dictionary for validity and presence of required fields
    return YES;
}

-(void)updatePeerInfo
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSLog(@"in secondary thread to update peer info");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        
        [[PASessionManager sharedClient] GET:usersAPI
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             //NSLog(@"JSON: %@",JSON);
             NSDictionary *usersDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [usersDictionary objectForKey:@"users"];
             for (NSDictionary *userAttributes in postsFromResponse) {
                 NSNumber *newID = [userAttributes objectForKey:@"id"];
                 BOOL userAlreadyExists = [self objectExists:newID withType:@"Peer" andCategory:nil];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 if(!userAlreadyExists && !([defaults objectForKey:@"user_id"]==newID)){
                     //NSLog(@"about to add the peer");
                     if(![[userAttributes objectForKey:first_name_define] isKindOfClass:[NSNull class]]){
                         Peer * peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext: _managedObjectContext];
                         [self setAttributesInPeer:peer withDictionary:userAttributes];
                     }
                     //NSLog(@"PEER: %@",peer);
                 }if(userAlreadyExists){
                     //if the peer is already in core data and is not the user
                     Peer* peer = [[PAFetchManager sharedFetchManager] getPeerWithID:newID];
                     if(peer){
                         [self setAttributesInPeer:peer withDictionary:userAttributes];
                     }
                 }
             }
         }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                     }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //TODO: if there are any problems with the core data being added in the thread above,
            // then we should add a separate managed object context and merge the two in this thread.
            
            
        });
    });

}


-(void)setAttributesInPeer:(Peer *)peer withDictionary:(NSDictionary *)dictionary
{
    //NSLog(@"set attributes of peer");
    NSString* fullName = [[dictionary objectForKey:first_name_define] stringByAppendingString:@" "];
    fullName = [fullName stringByAppendingString:[dictionary objectForKey:last_name_define]];
    peer.name = fullName;
    peer.id = [dictionary objectForKey:@"id"];
    if(![[dictionary objectForKey:@"image"] isEqualToString:@"/images/missing.png"]){
        peer.imageURL = [dictionary objectForKey:@"image"];
    }
}
#pragma mark - Like actions

-(void)likeComment:(NSInteger)commentID from:(NSString*)comment_from withCategory:(NSString*)category{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* authentication = [[self authenticationParameters] objectForKey:@"authentication"];
    NSDictionary* baseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    authentication, @"authentication",
                                    [defaults objectForKey:@"user_id"], @"liker",
                                    nil];
    
    NSString* likeURL = [@"api/comments/" stringByAppendingString:[@(commentID) stringValue]];
    likeURL = [likeURL stringByAppendingString:@"/add_like"];
    
    //NSLog(@"like url %@", likeURL);
    [[PASessionManager sharedClient] PATCH:likeURL
                              parameters:baseDictionary
                                success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                    //NSLog(@"like JSON %@", JSON);
                                    [self updateCommentsFrom:comment_from withCategory:category];
                                 }
    
                                   failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                       NSLog(@"ERROR: %@",error);
                                    
                                   }];
}
-(void)unlikeComment:(NSInteger)commentID from:(NSString*)comment_from withCategory:(NSString*)category{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* authentication = [[self authenticationParameters] objectForKey:@"authentication"];
    NSDictionary* baseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    authentication, @"authentication",
                                    [defaults objectForKey:@"user_id"], @"unliker",
                                    nil];
    
    NSString* likeURL = [@"api/comments/" stringByAppendingString:[@(commentID) stringValue]];
    likeURL = [likeURL stringByAppendingString:@"/unlike"];
    
    //NSLog(@"like url %@", likeURL);
    [[PASessionManager sharedClient] PATCH:likeURL
                                parameters:baseDictionary
                                   success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                       //NSLog(@"like JSON %@", JSON);
                                       [self updateCommentsFrom:comment_from withCategory:category];
                                   }
     
                                   failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                       NSLog(@"ERROR: %@",error);
                                       
                                   }];
}

#pragma mark - attend actions

-(void)attendEvent:(NSDictionary*) attendee forViewController:(UIViewController*)controller{
    
    
    [[PASessionManager sharedClient] POST:@"api/event_attendees"
                                parameters: [self applyWrapper:@"event_attendee" toDictionary:attendee]
                                   success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                       //NSLog(@"like JSON %@", JSON);
                                       
                                       
                                       //self set
                                       
                                        [self updateAndReloadEvent:[attendee objectForKey:@"event_attended"] forViewController:controller];
                                       
                                       //[self updateEventInfo];
                                   }
     
                                   failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                       NSLog(@"ERROR: %@",error);
                                       
                                   }];
}

-(void)unattendEvent:(NSDictionary*) attendee forViewController:(UIViewController*)controller{
    NSString* attendeeURL = @"api/event_attendees";
    [[PASessionManager sharedClient] DELETE:attendeeURL
                                 parameters: [self applyWrapper:@"event_attendee" toDictionary:attendee]
                                    success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                        //NSLog(@"like JSON %@", JSON);
                                        [self updateAndReloadEvent:[attendee objectForKey:@"event_attended"] forViewController:controller];
                                    }
     
                                    failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"ERROR: %@",error);
                                        
                                    }];

}

-(void)updateAndReloadEvent:(NSNumber*)eventID forViewController:(UIViewController*)controller{
    NSString* eventURL = [[simple_eventsAPI stringByAppendingString:@"/" ] stringByAppendingString:[eventID stringValue]];
    [[PASessionManager sharedClient] GET:eventURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"EVENT JSON: %@",JSON);
         NSDictionary* eventDictionary = (NSDictionary*)JSON;
         NSDictionary* eventAttributes = [eventDictionary objectForKey:@"simple_event"];
         Event* event = [[PAFetchManager sharedFetchManager] getObject:eventID withEntityType:@"Event" andType:@"simple"];
         [self setAttributesInEvent:event withDictionary:eventAttributes];
         if([controller isKindOfClass:[PAEventInfoTableViewController class]]){
             PAEventInfoTableViewController* sender = (PAEventInfoTableViewController*)controller;
             [sender configureView];
         }
         
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                     
                                 }];

}

#pragma mark - Institution actions

- (void)updateAvailableInstitutionsWithCallback:(void (^)(BOOL))callbackBlock
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        // no parameters needed here since the list of institutions is needed to get a user id
        [[PASessionManager sharedClient] GET:institutionsAPI
                                  parameters:[self authenticationParameters]
                                     success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                         //NSLog(@"update institutions JSON: %@",JSON);
                                         NSDictionary *institutionsDictionary = (NSDictionary*)JSON;
                                         NSArray *responseInstitutions = [institutionsDictionary objectForKey:@"institutions"];
                                         for (NSDictionary *institutionAttributes in responseInstitutions) {
                                             NSNumber * instID = [institutionAttributes objectForKey:@"id"];
                                             BOOL institutionAlreadyExists = [self objectExists:instID withType:@"Institution" andCategory:nil];
                                             if ( !institutionAlreadyExists ) {
                                                 //NSLog(@"Adding Institution: %@",[institutionAttributes objectForKey:@"name"]);
                                                 Institution * institution = [NSEntityDescription insertNewObjectForEntityForName:@"Institution" inManagedObjectContext:_managedObjectContext];
                                                 [self setAttributesInInstitution:institution withDictionary:institutionAttributes];
                                             }
                                         }
                                         callbackBlock(YES);
                                     }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                         callbackBlock(NO);
                                     }];
    });
}

-(void)setAttributesInInstitution:(Institution *)institution withDictionary:(NSDictionary *)dictionary
{
    // removes items not in the local model
    NSMutableDictionary * alteredDict = [dictionary mutableCopy];
    [alteredDict removeObjectsForKeys:@[@"configuration_id",@"api_key"]];
    // changes text dates to NSDate objects
   /* NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:serverDateFormat];
    
    [alteredDict setObject:[df dateFromString:[alteredDict objectForKey:@"created_at"]] forKey:@"created_at"];
    [alteredDict setObject:[df dateFromString:[alteredDict objectForKey:@"updated_at"]] forKey:@"updated_at"];*/
    
    [alteredDict setObject:[NSDate dateWithTimeIntervalSince1970:[[alteredDict objectForKey:@"created_at"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]] forKey:@"created_at"];
    [alteredDict setObject:[NSDate dateWithTimeIntervalSince1970:[[alteredDict objectForKey:@"updated_at"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]] forKey:@"updated_at"];
    
    // mass assignment to the object
    [institution setValuesForKeysWithDictionary:[alteredDict copy]];
    
    NSLog(@"set attributes of an institution");
}

#pragma mark - Explore tab actions

-(void)updateExploreInfo
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSLog(@"in secondary thread");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        [[PASessionManager sharedClient] GET:exploreAPI
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             //NSLog(@"explore JSON: %@",JSON);
             NSDictionary *exploreDictionary = (NSDictionary*)JSON;
             NSArray *eventsFromResponse = [exploreDictionary objectForKey:@"explore_events"];
             for (NSDictionary *eventAttributes in eventsFromResponse) {
                 NSNumber *newID = [eventAttributes objectForKey:@"id"];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Explore" andCategory:@"event"];
                 if(!eventAlreadyExists){
                     NSLog(@"about to add the explore event");
                     Explore * explore = [NSEntityDescription insertNewObjectForEntityForName:@"Explore" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInExplore:explore withDictionary:eventAttributes andCategory:@"event"];
                     //NSLog(@"EXPLORE: %@",explore);
                 }
             }
             NSDictionary* announcementsFromResponse = [exploreDictionary objectForKey:@"explore_announcements"];
             for(NSDictionary *announcementAttributes in announcementsFromResponse){
                 NSNumber *newID = [announcementAttributes objectForKey:@"id"];
                 BOOL announcementAlreadyExists = [self objectExists:newID withType:@"Explore" andCategory:@"announcement"];
                 if(!announcementAlreadyExists){
                     NSLog(@"about to add the explore announcement");
                     Explore * explore = [NSEntityDescription insertNewObjectForEntityForName:@"Explore" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInExplore:explore withDictionary:announcementAttributes andCategory:@"announcement"];
                 }
             }
         }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                     }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //TODO: if there are any problems with the core data being added in the thread above,
            // then we should add a separate managed object context and merge the two in this thread.
            
            
        });
    });

}

-(void)setAttributesInExplore:(Explore *) explore withDictionary: (NSDictionary *)dictionary andCategory:(NSString*)category{
    explore.title = [dictionary objectForKey:@"title"];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"];
    explore.start_date =[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"start_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    explore.end_date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"end_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    explore.id = [dictionary objectForKey:@"id"];
    explore.category = category;
    if(![[dictionary objectForKey:@"image"] isEqualToString:@"/images/missing.png"]){
        explore.imageURL = [dictionary objectForKey:@"image"];
    }
}

#pragma mark - Circles actions

-(void)postCircle: (NSDictionary *) dictionary
{

    [[PASessionManager sharedClient] POST:circlesAPI
                               parameters:[self applyWrapper:@"circle" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"post circle success: %@", JSON);
         /*NSDictionary *postsFromResponse = (NSDictionary*)JSON;
         NSDictionary *circleDictionary = [postsFromResponse objectForKey:@"circle"];
         //NSNumber *circleID = [circleDictionary objectForKey:@"id"];
         //[self addMembers:members ToCircle:circleID];*/
         [self updateCircleInfo];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
   
    
}

-(void)leaveCircle: (NSDictionary*) dictionary{
    [[PASessionManager sharedClient] DELETE:@"api/circle_members"
                               parameters:[self applyWrapper:@"circle_member" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"post circle member delete success: %@", JSON);
         
         [[PAFetchManager sharedFetchManager] removeCircle: [dictionary objectForKey:@"circle_id"]];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];

}

-(void)postCircleMember:(Peer*)newMember withDictionary:(NSDictionary *) dictionary forCircle:(Circle*)circle withSender:(id)sender{
    [[PASessionManager sharedClient] POST:circle_membersAPI
                               parameters:[self applyWrapper:@"circle_member" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         [circle addCircle_membersObject:newMember];
         PACircleCell *circleCell = (PACircleCell*)sender;
         [circleCell.profilesTableView reloadData];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
    

}

-(void)acceptCircleInvite:(NSNumber*)circleMemberID{
    
    /*
    [[PASessionManager sharedClient] PATCH:circle_membersAPI
                               parameters:[self applyWrapper:@"circle_member" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         [circle addCircle_membersObject:newMember];
         PACircleCell *circleCell = (PACircleCell*)sender;
         [circleCell.profilesTableView reloadData];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];*/
}

/*-(void)updateModifiedCircle:(Circle*)circle withSender:(id)sender forPeer:(Peer*)newMember{
    NSString* circleMembersURL = [circle_membersAPI stringByAppendingString:@"?"];
    circleMembersURL = [circleMembersURL stringByAppendingString:@"circle_id="];
    circleMembersURL = [circleMembersURL stringByAppendingString:[circle.id stringValue]];
    [[PASessionManager sharedClient] GET:circleMembersURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"The JSON: %@",JSON);
         NSDictionary *dictionary = (NSDictionary*)JSON ;
         NSArray*members = [dictionary objectForKey:@"circle_members"];
         Peer *addedMember =
         circle.members = members;
         PACirclesTableViewController *tableViewSender = (PACirclesTableViewController*)sender;
         [tableViewSender.tableView reloadData];
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];
}
*/

-(void)updateCircleInfo
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSLog(@"in secondary thread");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSString* circlesURL = [usersAPI stringByAppendingString:@"/"];
        circlesURL = [circlesURL stringByAppendingString:[[defaults objectForKey:@"user_id"] stringValue]];
        circlesURL = [circlesURL stringByAppendingString:@"/user_circles"];
        
        [[PASessionManager sharedClient] GET:circlesURL
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             //NSLog(@"update circle info JSON: %@",JSON);
             NSDictionary *circlesDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [circlesDictionary objectForKey:@"circles"];
             for (NSDictionary *circleAttributes in postsFromResponse) {
                 NSNumber *newID = [circleAttributes objectForKey:@"id"];
                 BOOL circleAlreadyExists = [self objectExists:newID withType:@"Circle" andCategory:nil];
                 if(!circleAlreadyExists){
                     //NSLog(@"about to add the circle");
                     Circle * circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInCircle:circle withDictionary:circleAttributes];
                     //NSLog(@"CIRCLE: %@",circle);
                 }
                 else{
                     //the circle already exists but we still want to change the attributes (in case a user leaves or the name is changed)
                     Circle* circle = [[PAFetchManager sharedFetchManager] getObject:newID withEntityType:@"Circle" andType:nil];
                     [self setAttributesInCircle:circle withDictionary:circleAttributes];
                 }
             }
         }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                     }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //TODO: if there are any problems with the core data being added in the thread above,
            // then we should add a separate managed object context and merge the two in this thread.
            
            
        });
    });

}

-(void)setAttributesInCircle:(Circle *)circle withDictionary:(NSDictionary *)dictionary
{
    //NSLog(@"set attributes of circle");
    circle.circleName = [dictionary objectForKey:@"circle_name"];
    //NSLog(@"circle name: %@", circle.circleName);
    circle.id = [dictionary objectForKey:@"id"];
    NSArray *members = (NSArray*)[dictionary objectForKey:@"circle_members"];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSSet* oldMembers = circle.circle_members;
    if(oldMembers){
        //In case a user leaves the circle. We need to remove all relationships and then add in the new ones
        [circle removeCircle_members:oldMembers];
    }
    for(int i =0; i<[members count]; i++){
        if([members[i] integerValue] != [[defaults objectForKey:@"user_id"] integerValue]){
            //Add the relationsip if the peer is not the user himself
            Peer *peer = [self getPeer:members[i]];
            if (peer != nil) {
                [circle addCircle_membersObject:peer];
            }
        }
    }
}

- (Peer *)getPeer:(NSNumber*)peerID{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"id";
    NSNumber *attributeValue = peerID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if([mutableFetchResults count]){
        Peer *peer = mutableFetchResults[0];
        return peer;
    }
    return nil;
    
}
#pragma mark - Peck actions

-(void)postPeck:(NSDictionary*)dictionary{
    [[PASessionManager sharedClient] POST:@"api/pecks"
                               parameters:[self applyWrapper:@"peck" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"peck JSON: %@", JSON);
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
    

}

-(void)updatePecks{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* peckURL = [@"api/pecks?user_id=" stringByAppendingString:[[defaults objectForKey:@"user_id"] stringValue]];
    [[PASessionManager sharedClient] GET:peckURL
                               parameters:[self authenticationParameters]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"peck JSON: %@", JSON);
         NSDictionary* json = (NSDictionary*)JSON;
         NSArray* pecks = [json objectForKey:@"pecks"];
         for(NSDictionary* peckAttributes in pecks){
             NSNumber* newID = [peckAttributes objectForKey:@"id"];
             BOOL peckAlreadyExists = [self objectExists:newID withType:@"Peck" andCategory:nil];
             if(!peckAlreadyExists){
                 Peck * peck = [NSEntityDescription insertNewObjectForEntityForName:@"Peck" inManagedObjectContext: _managedObjectContext];
                 [self setAttributesInPeck:peck withDictionary:peckAttributes];
             }
         }
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
    

}

-(void)setAttributesInPeck:(Peck*)peck withDictionary:(NSDictionary*)dictionary{
    peck.message = [dictionary objectForKey:@"message"];
    peck.id = [dictionary objectForKey:@"id"];
    peck.created_at=[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"created_at"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    if(![[dictionary objectForKey:@"invitation"] isKindOfClass:[NSNull class]]){
        peck.invitation_id =[dictionary objectForKey:@"invitation"];
    }
    
}

#pragma mark - Dining actions

-(void)updateDiningInfo{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSLog(@"in secondary thread to update dining");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSWeekdayCalendarUnit) fromDate:[NSDate date]];
        
        NSString* diningOpportunitiesURL = [dining_opportunitiesAPI stringByAppendingString:@"?day_of_week="];
        diningOpportunitiesURL = [diningOpportunitiesURL stringByAppendingString:[@([components weekday]-1) stringValue]];
        
        [[PASessionManager sharedClient] GET:diningOpportunitiesURL
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             NSDictionary *diningDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [diningDictionary objectForKey:@"dining_opportunities"];
             for (NSDictionary *diningAttributes in postsFromResponse){
                 NSNumber *newID = [diningAttributes objectForKey:@"id"];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Event" andCategory:nil];
                 if(!eventAlreadyExists){
                     Event * diningEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInDiningEvent:diningEvent withDictionary:diningAttributes];
                 }
             }
         }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                     }];
    });
    
}

-(void)setAttributesInDiningEvent:(Event*)diningEvent withDictionary:(NSDictionary*)dictionary{
    diningEvent.title= [dictionary objectForKey:@"dining_opportunity_type"];
    diningEvent.start_date=[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"start_time"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    diningEvent.end_date=[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"end_time"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    diningEvent.type = @"dining";
    diningEvent.id = [dictionary objectForKey:@"id"];
}


-(void)updateDiningPlaces:(DiningPeriod*)diningPeriod forController:(PADiningPlacesTableViewController*)viewController{
   //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
   //dispatch_async(queue, ^{
        NSString * diningPlacesURL = [dining_placesAPI stringByAppendingString:@"/"];
        //diningPlacesURL = [diningPlacesURL stringByAppendingString:@"id="];
        diningPlacesURL = [diningPlacesURL stringByAppendingString:[diningPeriod.place_id stringValue]];
    
        //NSLog(@"in secondary thread to update dining");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        [[PASessionManager sharedClient] GET:diningPlacesURL
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             NSLog(@"JSON: %@",JSON);
             NSDictionary *diningDictionary = (NSDictionary*)JSON;
             NSDictionary *diningAttributes = [diningDictionary objectForKey:@"dining_place"];
             NSNumber *newID = [diningAttributes objectForKey:@"id"];
             BOOL diningPlaceAlreadyExists = [self objectExists:newID withType:@"DiningPlace" andCategory:nil];
             if(!diningPlaceAlreadyExists){
                    NSLog(@"setting dining place");
                    DiningPlace * diningPlace = [NSEntityDescription insertNewObjectForEntityForName:@"DiningPlace" inManagedObjectContext: _managedObjectContext];
                    [self setAttributesInDiningPlace:diningPlace withDictionary:diningAttributes];
                    [viewController addDiningPlace:diningPlace withPeriod:diningPeriod];
                
             }
         }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                     }];
    //});

}

-(void)setAttributesInDiningPlace:(DiningPlace*)diningPlace withDictionary:(NSDictionary*)dictionary {
    diningPlace.name = [dictionary objectForKey:@"name"];
    diningPlace.id = [dictionary objectForKey:@"id"];
    //[diningPlace addDining_opportunityObject:diningEvent];
}


-(void)updateDiningPeriods:(Event*)diningOpportunity forViewController:(PADiningPlacesTableViewController*)viewController{
    NSString* diningPeriodsURL = [dining_periodsAPI stringByAppendingString:@"?dining_opportunity_id="];
    diningPeriodsURL = [diningPeriodsURL stringByAppendingString:[diningOpportunity.id stringValue]];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    diningPeriodsURL = [diningPeriodsURL stringByAppendingString:@"&day_of_week="];
    diningPeriodsURL = [diningPeriodsURL stringByAppendingString:[@([components weekday]-1) stringValue]];
    
    [[PASessionManager sharedClient] GET:diningPeriodsURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"dining period JSON %@", JSON);
         NSDictionary *periods = (NSDictionary*)JSON;
         NSArray * diningPeriodArray = [periods objectForKey:@"dining_periods"];
         NSMutableArray *diningPeriods = [[NSMutableArray alloc] init];
         for (NSDictionary *diningAttributes in diningPeriodArray){
             NSNumber *newID = [diningAttributes objectForKey:@"id"];
             BOOL diningPeriodAlreadyExists = [self objectExists:newID withType:@"DiningPeriod" andCategory:nil];
             if(!diningPeriodAlreadyExists){
                 //NSLog(@"setting dining period");
                 DiningPeriod * diningPeriod = [NSEntityDescription insertNewObjectForEntityForName:@"DiningPeriod" inManagedObjectContext: _managedObjectContext];
                 [self setAttributesInDiningPeriod:diningPeriod withDictionary:diningAttributes withDiningEvent:diningOpportunity];
                 [diningPeriods addObject:diningPeriod];
             }
         }
         for(int i=0;i<[diningPeriods count];i++){
             [viewController fetchDiningPlace:diningPeriods[i]];
         }
     }
     
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];

}

-(void)setAttributesInDiningPeriod:(DiningPeriod*)diningPeriod withDictionary:(NSDictionary*)dictionary withDiningEvent:(Event*)diningEvent{
    //NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //[df setDateFormat:serverDateFormat];

    diningPeriod.start_date =[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"start_time"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    diningPeriod.end_date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"end_time"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    //diningPeriod.start_date =[df dateFromString:[dictionary objectForKey:@"start_time"]];
    //diningPeriod.end_date = [df dateFromString:[dictionary objectForKey:@"end_time"]];
    diningPeriod.day_of_week = [dictionary objectForKey:@"day_of_week"];
    diningPeriod.id = [dictionary objectForKey:@"id"];
    diningPeriod.place_id=[dictionary objectForKey:@"dining_place_id"];
    diningPeriod.opportunity_id = diningEvent.id;
    
}
#pragma mark - Menu Item actions

-(void)updateMenuItemsForOpportunity:(Event*)diningOpportunity andPlace:(DiningPlace*)diningPlace{
    NSString * menuItemsURL = [menu_itemsAPI stringByAppendingString:@"?dining_opportunity_id="];
    menuItemsURL = [menuItemsURL stringByAppendingString:[diningOpportunity.id stringValue]];
    menuItemsURL = [menuItemsURL stringByAppendingString:@"&date_available="];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [df stringFromDate:[NSDate date]];
    menuItemsURL = [menuItemsURL stringByAppendingString:today];
    
    [[PASessionManager sharedClient] GET:menuItemsURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"menu items JSON %@", JSON);
         NSDictionary *items = (NSDictionary*)JSON;
         NSArray * menuItemArray = [items objectForKey:@"menu_items"];
         for (NSDictionary *menuItemAttributes in menuItemArray){
             NSNumber *newID = [menuItemAttributes objectForKey:@"id"];
             BOOL menuItemAlreadyExists = [self objectExists:newID withType:@"MenuItem" andCategory:nil];
             if(!menuItemAlreadyExists){
                 NSLog(@"setting menu Item");
                 MenuItem * menuItem = [NSEntityDescription insertNewObjectForEntityForName:@"MenuItem" inManagedObjectContext: _managedObjectContext];
                 [self setAttributesInMenuItem:menuItem withDictionary:menuItemAttributes andPlace:diningPlace andOpportunity:diningOpportunity];
             }
         }
    }
     
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];

    
}

-(void)setAttributesInMenuItem:(MenuItem*)menuItem withDictionary:(NSDictionary*)dictionary andPlace:(DiningPlace*)place andOpportunity:(Event*)opportunity{
    menuItem.name = [dictionary objectForKey:@"name"];
    menuItem.id = [dictionary objectForKey:@"id"];
    menuItem.dining_opportunity_id =opportunity.id;
    menuItem.dining_place_id =[dictionary objectForKey:@"dining_place_id"];
}

#pragma mark - Announcement actions

-(void)postAnnouncement:(NSDictionary*)dictionary withImage:(NSData*)imageData{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    NSInteger seconds = (NSInteger)nowEpochSeconds;
    
    NSString* fileName = [@"announcement_photo_" stringByAppendingString:[[defaults objectForKey:@"user_id" ] stringValue]];
    fileName = [fileName stringByAppendingString:@"_"];
    fileName = [fileName stringByAppendingString:[@(seconds) stringValue]];
    fileName = [fileName stringByAppendingString:@".jpeg"];
    //NSLog(@"file name %@", fileName);

    [[PASessionManager sharedClient] POST:announcementAPI
                               parameters:[self applyWrapper:@"announcement" toDictionary:dictionary]
                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];}
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"success: %@", JSON);
         [self updateExploreInfo];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
}


#pragma mark - Events actions

-(void)postEvent:(NSDictionary *)dictionary withImage:(NSData*)imageData
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    NSInteger seconds = (NSInteger)nowEpochSeconds;
    
    NSString* fileName = [@"event_photo_" stringByAppendingString:[[defaults objectForKey:@"user_id" ] stringValue]];
    fileName = [fileName stringByAppendingString:@"_"];
    fileName = [fileName stringByAppendingString:[@(seconds) stringValue]];
    fileName = [fileName stringByAppendingString:@".jpeg"];
    //NSLog(@"file name %@", fileName);
    
    //NSLog(@"file path: %@", filePath);
    [[PASessionManager sharedClient] POST:simple_eventsAPI
                               parameters:[self applyWrapper:@"simple_event" toDictionary:dictionary]
                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];}
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"simple event creation success: %@", JSON);
         [self updateEventInfo];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];

}

-(void)deleteEvent:(NSNumber*)eventID
{
    NSString *appendedURL = [@"api/simple_events/" stringByAppendingString:[eventID stringValue]];
    [[PASessionManager sharedClient] DELETE:appendedURL
                                 parameters:[self authenticationParameters]
                                    success:^
    (NSURLSessionDataTask * __unused task, id JSON) {
        //NSLog(@"success: %@", JSON);
    }
                                    failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"ERROR: %@",error);
                                    }];

}

-(void)updateEventInfo
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSLog(@"in secondary thread to update events");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        
        [[PASessionManager sharedClient] GET:simple_eventsAPI
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             //NSLog(@"EVENT JSON: %@",JSON);
             NSDictionary *eventsDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [eventsDictionary objectForKey:@"simple_events"];
             //NSLog(@"Update Event response: %@", postsFromResponse);
             NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
             for (NSDictionary *eventAttributes in postsFromResponse) {
                 NSNumber *newID = [eventAttributes objectForKey:@"id"];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Event" andCategory:nil];
                 if(!eventAlreadyExists){
                     //NSLog(@"adding an event to Core Data");
                     Event * event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInEvent:event withDictionary:eventAttributes];
                     [mutableEvents addObject:event];
                     //NSLog(@"EVENT: %@",event);
                 }else{
                     //the event is already in core data
                     Event* event = [[PAFetchManager sharedFetchManager] getObject:newID withEntityType:@"Event" andType:@"simple"];
                     [self setAttributesInEvent:event withDictionary:eventAttributes];
                 }
             }
             
         }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                     }];
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            
        });
         */
    });

    
}


-(void)setAttributesInEvent:(Event *)event withDictionary:(NSDictionary *)dictionary
{
    event.title = [dictionary objectForKey:@"title"];
    NSString * descrip = [dictionary objectForKey:@"event_description"];
    if (![descrip isKindOfClass:[NSNull class]]) {
        event.descrip = descrip;
    }
    //event.location = [dictionary objectForKey:@"institution_id"];
    event.id = [dictionary objectForKey:@"id"];
    event.type = @"simple";
    //event.isPublic = [[dictionary objectForKey:@"public"] boolValue];
    event.start_date =[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"start_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    event.end_date =[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"end_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    if(![[dictionary objectForKey:@"image"] isEqualToString:@"/images/missing.png"]){
        event.imageURL = [dictionary objectForKey:@"image"];
    }
    if(![[dictionary objectForKey:@"image"] isEqualToString:@"/images/missing.png"]){
        event.blurredImageURL = [dictionary objectForKey:@"blurred_image"];
    }
    event.attendees = [dictionary objectForKey:@"attendees"];
}

#pragma mark - Comment actions

-(void)postComment:(NSDictionary *)dictionary{
    [[PASessionManager sharedClient] POST:commentsAPI
                               parameters:[self applyWrapper:@"comment" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"success: %@", JSON);
         NSDictionary *commentsDictionary = (NSDictionary*)JSON;
         NSDictionary *commentAtrributes= [commentsDictionary objectForKey:@"comment"];
         //NSLog(@"comment atrributes: %@", commentAtrributes);
         NSNumber *comment_from = [commentAtrributes objectForKey:@"comment_from"];
         NSString *commentFromString = [comment_from stringValue];
         NSString *categoty = [commentAtrributes objectForKey:@"category"];
         [self updateCommentsFrom:commentFromString withCategory:categoty];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];

}

-(void)updateCommentsFrom: (NSString *)comment_from withCategory:(NSString *)category{
    if(comment_from){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
        
            NSLog(@"in secondary thread to update comments");
            PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
            _managedObjectContext = [appdelegate managedObjectContext];
            _persistentStoreCoordinator = [appdelegate persistentStoreCoordinator];
        
            NSString *specificCommentURL = [commentsAPI stringByAppendingString:@"?"];
            specificCommentURL = [specificCommentURL stringByAppendingString:@"category="];
            specificCommentURL = [specificCommentURL stringByAppendingString:category];
            specificCommentURL = [specificCommentURL stringByAppendingString:@"&"];
            specificCommentURL = [specificCommentURL stringByAppendingString:@"comment_from="];
            specificCommentURL = [specificCommentURL stringByAppendingString:comment_from];
        
            [[PASessionManager sharedClient] GET:specificCommentURL
                                      parameters:[self authenticationParameters]
                                         success:^
             (NSURLSessionDataTask * __unused task, id JSON) {
                 //NSLog(@"JSON: %@",JSON);
                 NSDictionary *commentsDictionary = (NSDictionary*)JSON;
                 NSArray *postsFromResponse = [commentsDictionary objectForKey:@"comments"];
                 //NSLog(@"Update Event response: %@", postsFromResponse);
                 for (NSDictionary *commentAttributes in postsFromResponse) {
                     NSNumber *newID = [commentAttributes objectForKey:@"id"];
                     BOOL eventAlreadyExists = [self objectExists:newID withType:@"Comment" andCategory:nil];
                     if(!eventAlreadyExists){
                         //NSLog(@"adding an event to Core Data");
                         [self.persistentStoreCoordinator lock];
                         Comment * comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext: _managedObjectContext];
                         [self setAttributesInComment:comment withDictionary:commentAttributes];
                         NSError* error = nil;
                         [_managedObjectContext save:&error];
                         [self.persistentStoreCoordinator unlock];
                         //NSLog(@"COMMENT: %@",comment);
                     }else{
                         [self.persistentStoreCoordinator lock];
                         Comment* comment = [[PAFetchManager sharedFetchManager] commentForID:newID];
                         [self setAttributesInComment:comment withDictionary:commentAttributes];
                         [self.persistentStoreCoordinator unlock];
                     }
                 }
             }
                                         failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                             NSLog(@"ERROR: %@",error);
                                         }];
        });
    
    }
}

-(void)setAttributesInComment:(Comment*)comment  withDictionary:(NSDictionary *)dictionary{
    if(![comment.content isEqualToString:[dictionary objectForKey:@"content"]]){
        comment.content = [dictionary objectForKey:@"content"];
    }
    comment.created_at = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"created_at"] doubleValue]];//+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    comment.id = [dictionary objectForKey:@"id"];
    comment.peer_id = [dictionary objectForKey:@"user_id"];
    comment.category = [dictionary objectForKey:@"category"];
    comment.comment_from = [dictionary objectForKey:@"comment_from"];
    comment.likes = [dictionary objectForKey:@"likes"];
}


#pragma mark - suscription actions

-(void)updateSubscriptions{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* institutionID = [[defaults objectForKey:@"institution_id"] stringValue];
    
    NSString* departmentSubscriptionURL = @"api/departments?institution_id=";
    departmentSubscriptionURL = [departmentSubscriptionURL stringByAppendingString:institutionID];
    
    [[PASessionManager sharedClient] GET:departmentSubscriptionURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"Subscription JSON: %@",JSON);
         NSDictionary *subscriptionDictionary = (NSDictionary*)JSON;
         NSArray *postsFromResponse = [subscriptionDictionary objectForKey:@"departments"];
         for (NSDictionary *departmentAttributes in postsFromResponse) {
             NSNumber *newID = [departmentAttributes objectForKey:@"id"];
             BOOL departmentAlreadyExists = [self objectExists:newID withType:@"Subscription" andCategory:@"department"];
             if(!departmentAlreadyExists){
                 //NSLog(@"adding an event to Core Data");
                 [self.persistentStoreCoordinator lock];
                 Subscription* subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext: _managedObjectContext];
                 [self setAttributesInSubscription:subscription withDictionary:departmentAttributes andCategory:@"department"];
                 NSError* error = nil;
                 [_managedObjectContext save:&error];
                 [self.persistentStoreCoordinator unlock];
                 //NSLog(@"SUBSCRIPTION: %@",subscription);
             }
         }
         [self updateSubscriptionsForCategory:@"department"];
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];
    
    NSString* clubSubscriptionURL = @"api/clubs?institution_id=";
    clubSubscriptionURL = [clubSubscriptionURL stringByAppendingString:institutionID];
    
    [[PASessionManager sharedClient] GET:clubSubscriptionURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"Subscription JSON: %@",JSON);
         NSDictionary *subscriptionDictionary = (NSDictionary*)JSON;
         NSArray *postsFromResponse = [subscriptionDictionary objectForKey:@"clubs"];
         for (NSDictionary *clubAttributes in postsFromResponse) {
             NSNumber *newID = [clubAttributes objectForKey:@"id"];
             BOOL clubAlreadyExists = [self objectExists:newID withType:@"Subscription" andCategory:@"club"];
             if(!clubAlreadyExists){
                 //NSLog(@"adding a subscription to Core Data");
                 [self.persistentStoreCoordinator lock];
                 Subscription* subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext: _managedObjectContext];
                 [self setAttributesInSubscription:subscription withDictionary:clubAttributes andCategory:@"club"];
                 NSError* error = nil;
                 [_managedObjectContext save:&error];
                 [self.persistentStoreCoordinator unlock];
                // NSLog(@"SUBSCRIPTION: %@",subscription);
             }
         }
         [self updateSubscriptionsForCategory:@"club"];
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];
    
    
    NSString* athleticSubscriptionURL = @"api/athletic_teams?institution_id=";
    athleticSubscriptionURL = [athleticSubscriptionURL stringByAppendingString:institutionID];
    
    [[PASessionManager sharedClient] GET:athleticSubscriptionURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"Subscription JSON: %@",JSON);
         NSDictionary *subscriptionDictionary = (NSDictionary*)JSON;
         NSArray *postsFromResponse = [subscriptionDictionary objectForKey:@"athletic_teams"];
         for (NSDictionary *athleticAttributes in postsFromResponse) {
             NSNumber *newID = [athleticAttributes objectForKey:@"id"];
             BOOL athleticAlreadyExists = [self objectExists:newID withType:@"Subscription" andCategory:@"athletic"];
             if(!athleticAlreadyExists){
                 //NSLog(@"adding a subscription to Core Data");
                 [self.persistentStoreCoordinator lock];
                 Subscription* subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext: _managedObjectContext];
                 [self setAttributesInSubscription:subscription withDictionary:athleticAttributes andCategory:@"athletic"];
                 NSError* error = nil;
                 [_managedObjectContext save:&error];
                 [self.persistentStoreCoordinator unlock];
                 //NSLog(@"SUBSCRIPTION: %@",subscription);
             }
         }
         [self updateSubscriptionsForCategory:@"athletic"];
         
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];

}

-(void)setAttributesInSubscription:(Subscription*)subscription withDictionary:(NSDictionary*)dictionary andCategory:(NSString*)category{
    if([category isEqualToString:@"department"]){
        subscription.name = [dictionary objectForKey:@"name"];
    }else if([category isEqualToString:@"club"]){
        subscription.name = [dictionary objectForKey:@"club_name"];
    }else if([category isEqualToString:@"athletic"]){
        NSString* sportName = [[dictionary objectForKey:@"gender"] stringByAppendingString:@"'s "];
        subscription.name = [sportName stringByAppendingString:[dictionary objectForKey:@"sport_name"]];
    }
    subscription.id = [dictionary objectForKey:@"id"];
    subscription.category = category;
}


-(void)postSubscriptions:(NSArray*)array{
    
    [[PASessionManager sharedClient] POST:subscriptionsAPI
                               parameters:[self applyWrapper:@"subscriptions" toArray:array]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"success: %@", JSON);
         [self updateSubscriptions];
         
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];

}

-(void)deleteSubscriptions:(NSArray*)array{
    // NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* stringFromArray = @"[";
    for(int i =0; i<[array count];i++){
        stringFromArray = [stringFromArray stringByAppendingString:[array[i] stringValue]];
        if(i!=([array count]-1)){
            stringFromArray = [stringFromArray stringByAppendingString:@","];
        }
    }
    stringFromArray = [stringFromArray stringByAppendingString:@"]"];
    //NSString* deleteURL = [subscriptionsAPI stringByAppendingString:@"/"];
    //deleteURL = [deleteURL stringByAppendingString:[[defaults objectForKey:@"user_id"] stringValue]];
    /*deleteURL = [deleteURL stringByAppendingString:@"?"];
    deleteURL = [deleteURL stringByAppendingString:@"subscriptions="];
    deleteURL = [deleteURL stringByAppendingString:stringFromArray];*/
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                stringFromArray, @"subscriptions",
                                nil];
    
   // NSLog(@"deleteURL: %@", deleteURL);
    
    [[PASessionManager sharedClient] DELETE:subscriptionsAPI
                                 parameters:[self applyWrapper:@"subscription" toDictionary:dictionary]
                                    success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"success: %@", JSON);
     }
                                    failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"ERROR: %@",error);
                                    }];

    
    
}

-(void)updateSubscriptionsForCategory:(NSString*)category{
    //three calls will be made to this method. It is necessary because the subscriptions must already be loaded into core date before we attemp to change its properties
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* subscriptionURL = [subscriptionsAPI stringByAppendingString:@"?user_id="];
    subscriptionURL = [subscriptionURL stringByAppendingString:[[defaults objectForKey:@"user_id" ] stringValue]];
    subscriptionURL = [subscriptionURL stringByAppendingString:@"&institution="];
    subscriptionURL = [subscriptionURL stringByAppendingString:[[defaults objectForKey:@"institution_id"] stringValue]];
    subscriptionURL = [subscriptionURL stringByAppendingString:@"&category="];
    subscriptionURL = [subscriptionURL stringByAppendingString:category];
    
    [[PASessionManager sharedClient] GET:subscriptionURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         //NSLog(@"Subscription JSON: %@",JSON);
         NSDictionary *subscriptionDictionary = (NSDictionary*)JSON;
         NSArray *postsFromResponse = [subscriptionDictionary objectForKey:@"subscriptions"];
         [[PAFetchManager sharedFetchManager] setAllSubscriptionsFalseForCategory:category];
         for (NSDictionary *subscriptionAttributes in postsFromResponse) {
             NSNumber* subID = [subscriptionAttributes objectForKey:@"subscribed_to"];
             NSNumber* subscriptionID = [subscriptionAttributes objectForKey:@"id"];
             //the sub id is the id of the department, club, or athletic team that the user is subscribed to
             //and the subscription id is the id of the acutal subscription (link between the user and subscription)
             [[PAFetchManager sharedFetchManager] setSubscribedTrue:subID withCategory:category andSubscriptionID:subscriptionID];
        }
         
         
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];

}


#pragma mark - Utility Methods



-(BOOL)objectExists:(NSNumber *) newID withType:(NSString*)type andCategory:(NSString*)category
{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *objects = [NSEntityDescription entityForName:type inManagedObjectContext:_managedObjectContext];
    [request setEntity:objects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", newID];
    NSMutableArray*predicateArray = [[NSMutableArray alloc] init];
    [predicateArray addObject:predicate];
    //[request setPredicate:predicate];
    
    if(category!=nil){
        NSPredicate* categoryPredicate = [NSPredicate predicateWithFormat:@"category like %@",category];
        [predicateArray addObject:categoryPredicate];
    }
    
    NSPredicate *compoundPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [request setPredicate:compoundPredicate];

    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    //fetch events in order to check if the events we want to add already exist in core data
    
    if([mutableFetchResults count]==0)
        return NO;
    else {
        return YES;
    }
}

- (NSDictionary*)authenticationParameters
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *userId = [defaults objectForKey:user_id];
    if (userId != nil) {
        [dict setObject:userId forKey:user_id];
    }
    
    NSNumber *instId = [defaults objectForKey:inst_id];
    if (instId != nil) {
        [dict setObject:instId forKey:inst_id];
    }
    
    NSString *apiKey = [defaults objectForKey:api_key];
    if (apiKey != nil) {
        [dict setObject:apiKey forKey:api_key];
    }
    
    NSString *authToken = [defaults objectForKey:auth_token];
    if (authToken != nil) {
        [dict setObject:authToken forKey:auth_token];
    }
    
    NSLog(@"authentication parameters: %@",dict);
    
    return [NSDictionary dictionaryWithObject:dict forKey:@"authentication"];
}

- (NSDictionary*)applyWrapper:(NSString*)wrapperString toDictionary:(NSDictionary*)dictionary
{
    NSMutableDictionary *baseDictionary = [[NSDictionary dictionaryWithObject:dictionary forKey:wrapperString] mutableCopy];
    
    //[baseDictionary setObject:[self authenticationParameters] forKey:@"authentication"];
    [baseDictionary setValuesForKeysWithDictionary:[self authenticationParameters]];
    
    NSLog(@"baseDictionary: %@",baseDictionary);
    
    return [baseDictionary copy];
}

- (NSDictionary*)applyWrapper:(NSString*)wrapperString toArray:(NSArray*)array {
    NSMutableDictionary *baseDictionary = [[NSDictionary dictionaryWithObject:array forKey:wrapperString] mutableCopy];
    
    [baseDictionary setValuesForKeysWithDictionary:[self authenticationParameters]];
    
    NSLog(@"baseDictionary: %@",baseDictionary);
    
    return [baseDictionary copy];
}


- (NSString*)currentInstitutionID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"];
}

// adds the unique user device token to any NSDictionary at the top level
- (NSDictionary*)addUDIDToDictionary:(NSDictionary *)dictionary {
    // adds the unique user device token to the userInfo NSDictionary
    NSUbiquitousKeyValueStore* store = [NSUbiquitousKeyValueStore defaultStore];
    NSMutableDictionary *mutDict = [dictionary mutableCopy];
    //[mutDict setObject:[store objectForKey:@"udid"] forKey:@"udid"];
    [mutDict setObject:shortTermUDID forKey:@"udid"];
    return [mutDict copy];
}

@end
