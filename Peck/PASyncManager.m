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

-(void)updateUserWithInfo:(NSDictionary *)userInfo
{
    NSString* updateURL = [usersAPI stringByAppendingString:@"/"];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* userID = [defaults objectForKey:@"user_id"];
    updateURL = [updateURL stringByAppendingString:[userID stringValue]];
    //updateURL = [updateURL stringByAppendingString:@"/update"];
    
    [[PASessionManager sharedClient] PATCH:updateURL
                                parameters:[self applyWrapper:@"user" toDictionary:userInfo]
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
                                        
                                        [defaults setObject:email forKey:@"email"];
                                        [defaults setObject:blurb forKey:@"blurb"];
                                        [defaults setObject:firstName forKey:@"first_name"];
                                        [defaults setObject:lastName forKey:@"last_name"];
                                      }
                                      failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                          NSLog(@"ERROR: %@",error);
                                      }];
    
}

- (void)authenticateUserWithInfo:(NSDictionary*)userInfo
{
    // sends either email and password, or facebook token and link, to the server for authentication
    // expects an authentication token to be returned in response
       
    /*NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
     [self authenticationParameters],@"authentication",
     [userInfo objectForKey:@"email" ], @"email",
     [userInfo objectForKey:@"password"], @"password",
     nil];*/
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
                                      
                                      [defaults setObject:firstName forKey:@"first_name"];
                                      [defaults setObject:lastName forKey:@"last_name"];
                                      [defaults setObject:email forKey:@"email"];
                                      [defaults setObject:userID forKey:@"user_id"];
                                      [defaults setObject:apiKey forKey:@"api_key"];
                                      if(![blurb isKindOfClass:[NSNull class]]){
                                          [defaults setObject:blurb forKey:@"blurb"];
                                      }
                                      [defaults setObject:[userDictionary objectForKey:@"authentication_token"] forKey:auth_token];

                                  }
     
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
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
                 BOOL userAlreadyExists = [self objectExists:newID withType:@"Peer"];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 if(!userAlreadyExists && !([defaults objectForKey:@"user_id"]==newID)){
                     //NSLog(@"about to add the peer");
                     if(![[userAttributes objectForKey:@"first_name"] isKindOfClass:[NSNull class]]){
                         Peer * peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext: _managedObjectContext];
                         [self setAttributesInPeer:peer withDictionary:userAttributes];
                     }
                     //NSLog(@"PEER: %@",peer);
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
                                             BOOL institutionAlreadyExists = [self objectExists:instID withType:@"Institution"];
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
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Explore"];
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
        
        
        [[PASessionManager sharedClient] GET:circlesAPI
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             //NSLog(@"update circle info JSON: %@",JSON);
             NSDictionary *circlesDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [circlesDictionary objectForKey:@"circles"];
             for (NSDictionary *circleAttributes in postsFromResponse) {
                 NSNumber *newID = [circleAttributes objectForKey:@"id"];
                 BOOL circleAlreadyExists = [self objectExists:newID withType:@"Circle"];
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
    NSMutableArray *addedMembers = [[NSMutableArray alloc] init];
    for(int i =0; i<[members count]; i++){
        addedMembers[i]=[self getPeer:members[i]];
        [circle addCircle_membersObject:[self getPeer:members[i]]];
        
    }
        //NSLog(@"circle members: %@", circle.circle_members);
    //circle.members = addedMembers;
    
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
    
    Peer *peer = mutableFetchResults[0];
    
    return peer;
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
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Event"];
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
        NSString * diningPlacesURL = [dining_placesAPI stringByAppendingString:@"?"];
        diningPlacesURL = [diningPlacesURL stringByAppendingString:@"id="];
        diningPlacesURL = [diningPlacesURL stringByAppendingString:[diningPeriod.place_id stringValue]];
    
        NSLog(@"in secondary thread to update dining");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        [[PASessionManager sharedClient] GET:diningPlacesURL
                                  parameters:[self authenticationParameters]
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             //NSLog(@"JSON: %@",JSON);
             NSDictionary *diningDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [diningDictionary objectForKey:@"dining_places"];
             for (NSDictionary *diningAttributes in postsFromResponse){
                 NSNumber *newID = [diningAttributes objectForKey:@"id"];
                 BOOL diningPlaceAlreadyExists = [self objectExists:newID withType:@"DiningPlace"];
                 if(!diningPlaceAlreadyExists){
                     NSLog(@"setting dining place");
                     DiningPlace * diningPlace = [NSEntityDescription insertNewObjectForEntityForName:@"DiningPlace" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInDiningPlace:diningPlace withDictionary:diningAttributes];
                     [viewController addDiningPlace:diningPlace withPeriod:diningPeriod];
                 }
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
         NSDictionary *periods = (NSDictionary*)JSON;
         NSArray * diningPeriodArray = [periods objectForKey:@"dining_periods"];
         NSMutableArray *diningPeriods = [[NSMutableArray alloc] init];
         for (NSDictionary *diningAttributes in diningPeriodArray){
             NSNumber *newID = [diningAttributes objectForKey:@"id"];
             BOOL diningPeriodAlreadyExists = [self objectExists:newID withType:@"DiningPeriod"];
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
         NSDictionary *items = (NSDictionary*)JSON;
         NSArray * menuItemArray = [items objectForKey:@"menu_items"];
         for (NSDictionary *menuItemAttributes in menuItemArray){
             NSNumber *newID = [menuItemAttributes objectForKey:@"id"];
             BOOL menuItemAlreadyExists = [self objectExists:newID withType:@"MenuItem"];
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

-(void)postEvent:(NSDictionary *)dictionary
{
    [[PASessionManager sharedClient] POST:simple_eventsAPI
                              parameters:[self applyWrapper:@"simple_event" toDictionary:dictionary]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"success: %@", JSON);
         //[self updateEventInfo];
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
             //NSLog(@"JSON: %@",JSON);
             NSDictionary *eventsDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [eventsDictionary objectForKey:@"simple_events"];
             //NSLog(@"Update Event response: %@", postsFromResponse);
             NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
             for (NSDictionary *eventAttributes in postsFromResponse) {
                 NSNumber *newID = [eventAttributes objectForKey:@"id"];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Event"];
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
    event.descrip = [dictionary objectForKey:@"event_description"];
    //event.location = [dictionary objectForKey:@"institution_id"];
    event.id = [dictionary objectForKey:@"id"];
    event.type = @"simple";
    //event.isPublic = [[dictionary objectForKey:@"public"] boolValue];
    event.start_date =[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"start_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    event.end_date =[NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"end_date"] doubleValue]+[[NSTimeZone systemTimeZone] secondsFromGMT]];
    
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
                     BOOL eventAlreadyExists = [self objectExists:newID withType:@"Comment"];
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




#pragma mark - Utility Methods

-(BOOL)objectExists:(NSNumber *) newID withType:(NSString*)type
{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *objects = [NSEntityDescription entityForName:type inManagedObjectContext:_managedObjectContext];
    [request setEntity:objects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", newID];
    [request setPredicate:predicate];
    
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


-(NSString*)currentInstitutionID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"];
}

@end
