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

#define serverDateFormat @"yyyy-MM-dd'T'kk:mm:ss.SSS'Z'"


@implementation PASyncManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;
//NSDateFormatter * df;


+ (instancetype)globalSyncManager
{
    static PASyncManager *_globalSyncManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalSyncManager = [[PASyncManager alloc] init];
    });
    
    return _globalSyncManager;
}

#pragma mark - User actions

-(void)sendUserDeviceToken:(NSString*)deviceToken{
    NSString* userURL = [usersAPI stringByAppendingString:@"/user_for_device_token"];
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                deviceToken, @"user_device_token",
                                nil];
    
    [[PASessionManager sharedClient] POST:userURL
                               parameters:dictionary
                                  success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                      NSLog(@"Device Token JSON: %@", JSON);
                                  }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                      
                                  }];

    
}

-(void)ceateAnonymousUser:(void (^)(BOOL))callbackBlock
{
    NSLog(@"creating an anonymous new user");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[PASessionManager sharedClient] POST:usersAPI
                               parameters:nil
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
                                        NSString* firstName = [userDictionary objectForKey:@"first_name"];
                                        NSString* lastName = [userDictionary objectForKey:@"last_name"];
                                        NSString* imageURL = [userDictionary objectForKey:@"image"];
                                        
                                        [defaults setObject:email forKey:@"email"];
                                        [defaults setObject:blurb forKey:@"blurb"];
                                        [defaults setObject:firstName forKey:@"first_name"];
                                        [defaults setObject:lastName forKey:@"last_name"];
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
    // sends either email and password, or facebook token and link, to the server for authentication
    // expects an authentication token to be returned in response
    
    [[PASessionManager sharedClient] POST: @"api/access"
                               parameters:[self applyWrapper:@"user" toDictionary:userInfo]
                                  success:^(NSURLSessionDataTask * __unused task, id JSON){
                                      NSLog(@"LOGIN JSON: %@",JSON);
                                      
                                      
                                      
                                      NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                      NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                      NSString* firstName = [userDictionary objectForKey:@"first_name"];
                                      NSString* lastName = [userDictionary objectForKey:@"last_name"];
                                      NSString* email = [userDictionary objectForKey:@"email"];
                                      NSString* blurb = [userDictionary objectForKey:@"blurb"];
                                      NSNumber* userID = [userDictionary objectForKey:@"id"];
                                      NSString* apiKey = [userDictionary objectForKey:@"api_key"];
                                      NSString* imageURL = [userDictionary objectForKey:@"image"];
                                      
                                      [defaults setObject:firstName forKey:@"first_name"];
                                      [defaults setObject:lastName forKey:@"last_name"];
                                      [defaults setObject:email forKey:@"email"];
                                      [defaults setObject:userID forKey:@"user_id"];
                                      [defaults setObject:apiKey forKey:@"api_key"];
                                      
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
                                      
                                      if(![blurb isKindOfClass:[NSNull class]]){
                                          [defaults setObject:blurb forKey:@"blurb"];
                                      }
                                      [defaults setObject:[userDictionary objectForKey:@"authentication_token"] forKey:auth_token];
                                      [self updateSubscriptions];
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
                                      NSLog(@"user register success: %@", JSON);
                                      NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                      NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                      NSString* firstName = [userDictionary objectForKey:@"first_name"];
                                      NSString* lastName = [userDictionary objectForKey:@"last_name"];
                                      NSString* email = [userDictionary objectForKey:@"email"];
                                      NSString* blurb = [userDictionary objectForKey:@"blurb"];
                                      [defaults setObject:firstName forKey:@"first_name"];
                                      [defaults setObject:lastName forKey:@"last_name"];
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
    NSLog(@"passwordURL: %@", passwordURL);
    
    [[PASessionManager sharedClient] PATCH:passwordURL
                                parameters:[self applyWrapper:@"user" toDictionary:passwordInfo]
                                   success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                       NSLog(@"password JSON: %@",JSON);
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
             NSLog(@"JSON: %@",JSON);
             NSDictionary *usersDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [usersDictionary objectForKey:@"users"];
             for (NSDictionary *userAttributes in postsFromResponse) {
                 NSNumber *newID = [userAttributes objectForKey:@"id"];
                 BOOL userAlreadyExists = [self objectExists:newID withType:@"Peer" andCategory:nil];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 if(!userAlreadyExists && !([defaults objectForKey:@"user_id"]==newID)){
                     //NSLog(@"about to add the peer");
                     if(![[userAttributes objectForKey:@"first_name"] isKindOfClass:[NSNull class]]){
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
    NSString* fullName = [[dictionary objectForKey:@"first_name"] stringByAppendingString:@" "];
    fullName = [fullName stringByAppendingString:[dictionary objectForKey:@"last_name"]];
    peer.name = fullName;
    peer.id = [dictionary objectForKey:@"id"];
    if(![[dictionary objectForKey:@"image"] isEqualToString:@"/images/missing.png"]){
        peer.imageURL = [dictionary objectForKey:@"image"];
    }
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
             NSDictionary *eventsDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [eventsDictionary objectForKey:@"explore"];
             for (NSDictionary *eventAttributes in postsFromResponse) {
                 NSNumber *newID = [eventAttributes objectForKey:@"id"];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Explore" andCategory:nil];
                 if(!eventAlreadyExists){
                     NSLog(@"about to add the explore");
                     Explore * explore = [NSEntityDescription insertNewObjectForEntityForName:@"Explore" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInExplore:explore withDictionary:eventAttributes];
                     //NSLog(@"EXPLORE: %@",explore);
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

-(void)setAttributesInExplore:(Explore *) explore withDictionary: (NSDictionary *)dictionary{
    explore.title = [dictionary objectForKey:@"title"];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"];
    explore.start_date =[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"start_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    explore.end_date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"end_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    explore.id = [dictionary objectForKey:@"id"];
}

#pragma mark - Circles actions

-(void)postCircle: (NSDictionary *) dictionary
{

    [[PASessionManager sharedClient] POST:circlesAPI
                               parameters:[self applyWrapper:@"circle" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"post circle success: %@", JSON);
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
             NSLog(@"update circle info JSON: %@",JSON);
             NSDictionary *circlesDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [circlesDictionary objectForKey:@"circles"];
             for (NSDictionary *circleAttributes in postsFromResponse) {
                 NSNumber *newID = [circleAttributes objectForKey:@"id"];
                 BOOL circleAlreadyExists = [self objectExists:newID withType:@"Circle" andCategory:nil];
                 if(!circleAlreadyExists){
                     NSLog(@"about to add the circle");
                     Circle * circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInCircle:circle withDictionary:circleAttributes];
                     //NSLog(@"CIRCLE: %@",circle);
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
    NSLog(@"set attributes of circle");
    circle.circleName = [dictionary objectForKey:@"circle_name"];
    NSLog(@"circle name: %@", circle.circleName);
    circle.id = [dictionary objectForKey:@"id"];
    NSArray *members = (NSArray*)[dictionary objectForKey:@"circle_members"];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    for(int i =0; i<[members count]; i++){
        if([members[i] integerValue] != [[defaults objectForKey:@"user_id"] integerValue]){
            //Add the relationsip if the peer is not the user himself
            [circle addCircle_membersObject:[self getPeer:members[i]]];
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
    
        NSLog(@"in secondary thread to update dining");
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
                 NSLog(@"setting dining period");
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
         NSLog(@"menu items JSON %@", JSON);
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

#pragma mark - Events actions

-(void)postEvent:(NSDictionary *)dictionary withImage:(NSData*)filePath
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate* now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    NSInteger seconds = (NSInteger)nowEpochSeconds;
    
    NSString* fileName = [@"event_photo_" stringByAppendingString:[[defaults objectForKey:@"user_id" ] stringValue]];
    fileName = [fileName stringByAppendingString:@"_"];
    fileName = [fileName stringByAppendingString:[@(seconds) stringValue]];
    fileName = [fileName stringByAppendingString:@".jpeg"];
    NSLog(@"file name %@", fileName);
    
    //NSLog(@"file path: %@", filePath);
    [[PASessionManager sharedClient] POST:simple_eventsAPI
                               parameters:[self applyWrapper:@"simple_event" toDictionary:dictionary]
                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) { [formData appendPartWithFileData:filePath name:@"image" fileName:fileName mimeType:@"image/jpeg"];}
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"success: %@", JSON);
         [self updateEventInfoForViewController:nil];
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
        NSLog(@"success: %@", JSON);
    }
                                    failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"ERROR: %@",error);
                                    }];

}

-(void)updateEventInfoForViewController:(UIViewController*)controller
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
             //NSLog(@"JSON: %@",JSON);
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
}

#pragma mark - Comment actions

-(void)postComment:(NSDictionary *)dictionary{
    [[PASessionManager sharedClient] POST:commentsAPI
                               parameters:[self applyWrapper:@"comment" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"success: %@", JSON);
         NSDictionary *commentsDictionary = (NSDictionary*)JSON;
         NSDictionary *commentAtrributes= [commentsDictionary objectForKey:@"comment"];
         NSLog(@"comment atrributes: %@", commentAtrributes);
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
                         NSLog(@"COMMENT: %@",comment);
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
    comment.content = [dictionary objectForKey:@"content"];
    
   /* NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:serverDateFormat];
    comment.created_at = [df dateFromString:[dictionary objectForKey:@"created_at"]];*/
    comment.created_at = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"created_at"] doubleValue]];//+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    comment.id = [dictionary objectForKey:@"id"];
    comment.peer_id = [dictionary objectForKey:@"user_id"];
    comment.category = [dictionary objectForKey:@"category"];
    comment.comment_from = [dictionary objectForKey:@"comment_from"];
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
                 NSLog(@"adding an event to Core Data");
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
                 NSLog(@"adding a subscription to Core Data");
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
                 NSLog(@"adding a subscription to Core Data");
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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* stringFromArray = @"[";
    for(int i =0; i<[array count];i++){
        stringFromArray = [stringFromArray stringByAppendingString:[array[i] stringValue]];
        if(i!=([array count]-1)){
            stringFromArray = [stringFromArray stringByAppendingString:@","];
        }
    }
    stringFromArray = [stringFromArray stringByAppendingString:@"]"];
    NSString* deleteURL = [subscriptionsAPI stringByAppendingString:@"/"];
    deleteURL = [deleteURL stringByAppendingString:[[defaults objectForKey:@"user_id"] stringValue]];
    deleteURL = [deleteURL stringByAppendingString:@"?"];
    deleteURL = [deleteURL stringByAppendingString:@"subscriptions="];
    deleteURL = [deleteURL stringByAppendingString:stringFromArray];
    
    NSLog(@"deleteURL: %@", deleteURL);
    
    [[PASessionManager sharedClient] DELETE:deleteURL
                                 parameters:[self authenticationParameters]
                                    success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"success: %@", JSON);
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

-(NSDictionary*)applyWrapper:(NSString*)wrapperString toArray:(NSArray*)array{
    NSMutableDictionary *baseDictionary = [[NSDictionary dictionaryWithObject:array forKey:wrapperString] mutableCopy];
    
    [baseDictionary setValuesForKeysWithDictionary:[self authenticationParameters]];
    
    NSLog(@"baseDictionary: %@",baseDictionary);
    
    return [baseDictionary copy];
}


-(NSString*)currentInstitutionID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"];
}

@end
