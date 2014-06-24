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


-(void)updateEventInfo{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    

    [[PASessionManager sharedClient] GET:@"api/events"
                              parameters:nil
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"JSON: %@",JSON);
         NSArray *postsFromResponse = (NSArray*)JSON;
         NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
         for (NSDictionary *eventAttributes in postsFromResponse) {
             NSString *newID = [[eventAttributes objectForKey:@"id"] stringValue];
             BOOL eventAlreadyExists = [self eventExists:newID];
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
    
    /*
     [[PASessionManager sharedClient] POST:@"api/events"
     parameters:@{}
     success:^(NSURLSessionDataTask *task,id responseObject) {
     NSLog(@"POST success: %@",responseObject);
     }
     failure:^(NSURLSessionDataTask *task, NSError * error) {
     NSLog(@"POST error: %@",error);
     }];
     */
}

-(BOOL)eventExists:(NSString *) newID{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *events = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    [request setEntity:events];
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
    event.descrip = [dictionary objectForKey:@"description"];
    event.location = [dictionary objectForKey:@"institution"];
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
