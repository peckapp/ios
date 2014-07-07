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

#define serverDateFormat @"yyyy-MM-dd'T'kk:mm:ss.SSS'Z'"


@implementation PASyncManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
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

-(void)ceateAnonymousUser
{
    NSLog(@"creating an anonymous new user");
    // creates an anonymous user sending just the currently chosen institution_id as a parameter
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int inst = (int)[defaults objectForKey:@"institution_id"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:inst],@"institution_id",
                                    @"test_username",@"username",
                                    nil];
    
    [[PASessionManager sharedClient] POST:usersAPI
                                    parameters:[self applyWrapper:@"user" toDictionary:dictionary]
                                    success:^
    (NSURLSessionDataTask * __unused task, id JSON) {
        // response JSON contains a user_id and api_key that must be stored
        NSLog(@"Anonymous user creation success: %@", JSON);
        NSDictionary *postsFromResponse = (NSDictionary*)JSON;
        NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
        
        //store new information from server response
        NSNumber *userID = [userDictionary objectForKey:@"id"];
        [defaults setObject:userID forKey:user_id];
        NSString *apiKey = [userDictionary objectForKey:api_key];
        [defaults setObject:apiKey forKey:api_key];
    }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
}

-(void)updateUserWithInfo:(NSDictionary *)userInfo
{
    if ([self validUserInfo:userInfo]) {
        [[PASessionManager sharedClient] POST:usersAPI
                                   parameters:[self applyWrapper:@"user" toDictionary:userInfo]
                                      success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                          // extract core dictionary from json
                                          NSLog(@"Update user success: %@", JSON);
                                          NSDictionary *postsFromResponse = (NSDictionary*)JSON;
                                          NSDictionary *userDictionary = [postsFromResponse objectForKey:@"user"];
                                          
                                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                          
                                          NSNumber *userID = [userDictionary objectForKey:@"id"];
                                          [defaults setObject:userID forKey:@"user_id"];
                                      }
                                      failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                          NSLog(@"ERROR: %@",error);
                                      }];
    }
    
}

- (void)authenticateUserWithInfo:(NSDictionary*)userInfo
{
    // sends either email and password, or facebook token and link, to the server for authentication
    // expects an authentication token to be returned in response
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
                     Peer * peer = [NSEntityDescription insertNewObjectForEntityForName:@"Peer" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInPeer:peer withDictionary:userAttributes];
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
    peer.name = [dictionary objectForKey:@"first_name"];
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
                                  parameters:nil
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
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:serverDateFormat];
    [alteredDict setObject:[df dateFromString:[alteredDict objectForKey:@"created_at"]] forKey:@"created_at"];
    [alteredDict setObject:[df dateFromString:[alteredDict objectForKey:@"updated_at"]] forKey:@"updated_at"];
    
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
    explore.start_date = [df dateFromString:[dictionary valueForKey:@"start_date"]];
    explore.end_date = [df dateFromString:[dictionary valueForKey:@"end_date"]];
    explore.id = [dictionary objectForKey:@"id"];
}

#pragma mark - Circles actions

-(void)postCircle: (NSDictionary *) dictionary withMembers:(NSArray *)members
{
    
    [[PASessionManager sharedClient] POST:circlesAPI
                               parameters:[self applyWrapper:@"circle" toDictionary:dictionary]
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"post circle success: %@", JSON);
         NSDictionary *postsFromResponse = (NSDictionary*)JSON;
         NSDictionary *circleDictionary = [postsFromResponse objectForKey:@"circle"];
         NSNumber *circleID = [circleDictionary objectForKey:@"id"];
         [self addMembers:members ToCircle:circleID];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
    
    
   
    
}

-(void)addMembers:(NSArray *)members ToCircle:(NSNumber*)circleID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * userID = [defaults objectForKey:@"user_id"];
    
    for(int i=0; i<[members count]; i++){
        Peer *tempPeer = members[i];
        NSNumber *peerID = tempPeer.id;
        NSDictionary *tempDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        peerID, @"user_id",
                                        userID, @"invited_by",
                                        circleID, @"circle_id",
                                        nil];
        
        NSString *circleMembersURL = [@"api/circles/" stringByAppendingString:[circleID stringValue]];
        circleMembersURL = [circleMembersURL stringByAppendingString:@"/circle_members"];
        
        [[PASessionManager sharedClient] POST:circleMembersURL
                                   parameters:[self applyWrapper:@"circle_member" toDictionary:tempDictionary]
                                      success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                          NSLog(@"add circle members success: %@", JSON);
                                      }
                                      failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                          NSLog(@"ERROR: %@",error);
                                      }];
        
    }
}

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
             NSLog(@"update circle info JSON: %@",JSON);
             NSDictionary *eventsDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [eventsDictionary objectForKey:@"circles"];
             NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
             for (NSDictionary *eventAttributes in postsFromResponse) {
                 NSNumber *newID = [eventAttributes objectForKey:@"id"];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Circle"];
                 if(!eventAlreadyExists){
                     NSLog(@"about to add the circle");
                     Circle * circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInCircle:circle withDictionary:eventAttributes];
                     [mutableEvents addObject:circle];
                     NSLog(@"CIRCLE: %@",circle);
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
    circle.id = [dictionary objectForKey:@"id"];
    circle.members = (NSArray*)[dictionary objectForKey:@"circle_members"];
    
    /*NSString *circleMembersURL = [@"api/circles/" stringByAppendingString:[circle.id stringValue]];
    circleMembersURL = [circleMembersURL stringByAppendingString:@"/circle_members"];
    [[PASessionManager sharedClient] GET:circleMembersURL
                              parameters:[self authenticationParameters]
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"circle members url: %@", circleMembersURL);
         NSLog(@"the circle json: %@", JSON);
         NSMutableArray *members = [NSMutableArray array];
         NSDictionary *eventsDictionary = (NSDictionary*)JSON;
         NSArray *postsFromResponse = [eventsDictionary objectForKey:@"circle_members"];
         for(NSDictionary * peerAttributes in postsFromResponse){
             NSNumber *memberID = [peerAttributes objectForKey:@"user_id"];
             [members addObject:memberID];
         }
         circle.members = members;
         NSLog(@"circle members: %@", members);
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];*/
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
    //event.isPublic = [[dictionary objectForKey:@"public"] boolValue];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:serverDateFormat];
    
    event.start_date = [df dateFromString:[dictionary valueForKey:@"start_date"]];
    event.end_date = [df dateFromString:[dictionary valueForKey:@"end_date"]];
    
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSLog(@"in secondary thread to update comments");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
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
                     Comment * comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInComment:comment withDictionary:commentAttributes];
                     //NSLog(@"EVENT: %@",event);
                 }
             }
         }
                                     failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                         NSLog(@"ERROR: %@",error);
                                     }];
    });
    

}

-(void)setAttributesInComment:(Comment*)comment  withDictionary:(NSDictionary *)dictionary{
    comment.content = [dictionary objectForKey:@"content"];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:serverDateFormat];
    comment.created_at = [df dateFromString:[dictionary objectForKey:@"created_at"]];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", newID];
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
