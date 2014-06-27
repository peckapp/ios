//
//  PASyncManager.m
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASyncManager.h"
#import "PAAppDelegate.h"
#import "Event.h"
#import "Circle.h"
#import "PASessionManager.h"

@implementation PASyncManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;




+ (instancetype)globalSyncManager {
    static PASyncManager *_globalSyncManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalSyncManager = [[PASyncManager alloc] init];
    });
    
    return _globalSyncManager;
}

-(void)setUser{
    NSLog(@"setting the new user");
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"John", @"first_name",
                                    @"Doe", @"last_name",
                                    @"guest", @"username",
                                    [NSNumber numberWithInt:1],@"institution_id",
                                    @"apiKEY",@"api_key",
                                    nil];
    [[PASessionManager sharedClient] POST:@"api/users"
                                    parameters:dictionary
                                    success:^
    (NSURLSessionDataTask * __unused task, id JSON) {
        NSLog(@"success: %@", JSON);
    }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];

    [[PASessionManager sharedClient] GET:@"api/users"
                               parameters:nil
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"JSON: %@",JSON);
         NSDictionary *eventsDictionary = (NSDictionary*)JSON;
         NSArray *postsFromResponse = [eventsDictionary objectForKey:@"circles"];
         NSDictionary *userDictionary = postsFromResponse[0];
         NSString *userID = [userDictionary objectForKey:@"user_id"];
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         [defaults setObject:userID forKey:@"user_id"];
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];

}


-(void)postCircle: (NSDictionary *) dictionary withMembers:(NSArray *)members{
    
    [[PASessionManager sharedClient] POST:@"api/users"
                               parameters:dictionary
                                  success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"success: %@", JSON);
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];
    
    /*
    for(int i=0; i<[members count]; i++){
        NSDictionary *tempDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        
                                        , nil];
        
        
    }*/
    
}

-(void)updateCircleInfo{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSLog(@"in secondary thread");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        
        [[PASessionManager sharedClient] GET:@"api/circles"
                                  parameters:nil
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             NSLog(@"JSON: %@",JSON);
             NSDictionary *eventsDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [eventsDictionary objectForKey:@"circles"];
             NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
             for (NSDictionary *eventAttributes in postsFromResponse) {
                 NSString *newID = [[eventAttributes objectForKey:@"id"] stringValue];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Circle"];
                 if(!eventAlreadyExists){
                     NSLog(@"about to add the event");
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
    NSLog(@"set attributes of event");
    circle.circleName = [dictionary objectForKey:@"circle_name"];
    
    NSString *tempString = [[dictionary objectForKey:@"id"] stringValue];
    circle.id = tempString;
}

-(void)postEvent:(NSDictionary *)dictionary{
    
    [[PASessionManager sharedClient] POST:@"api/simple_events"
                              parameters:dictionary
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"success: %@", JSON);
     }
                                  failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                      NSLog(@"ERROR: %@",error);
                                  }];

}

-(void)deleteEvent:(NSString*)eventID{
    
    NSString *appendedURL = [@"api/simple_events/" stringByAppendingString:eventID];
    [[PASessionManager sharedClient] DELETE:appendedURL
                                parameters:nil success:^
    (NSURLSessionDataTask * __unused task, id JSON) {
        NSLog(@"success: %@", JSON);
    }
                                    failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        NSLog(@"ERROR: %@",error);
                                    }];

}

-(void)updateEventInfo{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSLog(@"in secondary thread");
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
        
        
        [[PASessionManager sharedClient] GET:@"api/simple_events"
                                  parameters:nil
                                     success:^
         (NSURLSessionDataTask * __unused task, id JSON) {
             NSLog(@"JSON: %@",JSON);
             NSDictionary *eventsDictionary = (NSDictionary*)JSON;
             NSArray *postsFromResponse = [eventsDictionary objectForKey:@"simple_events"];
             NSLog(@"posts from response: %@", postsFromResponse);
             NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
             for (NSDictionary *eventAttributes in postsFromResponse) {
                 NSString *newID = [[eventAttributes objectForKey:@"id"] stringValue];
                 BOOL eventAlreadyExists = [self objectExists:newID withType:@"Event"];
                 if(!eventAlreadyExists){
                     NSLog(@"about to add the event");
                     Event * event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext: _managedObjectContext];
                     [self setAttributesInEvent:event withDictionary:eventAttributes];
                     [mutableEvents addObject:event];
                     NSLog(@"EVENT: %@",event);
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

-(BOOL)objectExists:(NSString *) newID withType:(NSString*)type{
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

-(void)setAttributesInEvent:(Event *)event withDictionary:(NSDictionary *)dictionary
{
    NSLog(@"set attributes of event");
    event.title = [dictionary objectForKey:@"title"];
    //event.descrip = [dictionary objectForKey:@"event_description"];
    //event.location = [dictionary objectForKey:@"institution_id"];
    NSString *tempString = [[dictionary objectForKey:@"id"] stringValue];
    event.id = tempString;
    //event.isPublic = [[dictionary objectForKey:@"public"] boolValue];
    //NSDateFormatter * df = [[NSDateFormatter alloc] init];
    //event.startDate = [df dateFromString:[attributes valueForKey:@"start_date"]];
    //event.endDate = [df dateFromString:[attributes valueForKey:@"end_date"]];
    
    // the below doesn't work due to current disparity between the json and coredata terminology
    /*
     NSDictionary *attributes = [[event entity] attributesByName];
     for (NSString *attribute in attributes) {
     id value = [dictionary objectForKey:attribute];
     if (value == nil) {
     continue;
     }
     [event setValue:value forKey:attribute];
     }
     */
}

@end
