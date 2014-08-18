//
//  PAFetchManager.m
//  Peck
//
//  Created by John Karabinos on 7/21/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFetchManager.h"
#import "PAAppDelegate.h"
#import "Peer.h"
#import "PASyncManager.h"
#import "Subscription.h"
#import "Comment.h"
#import "Institution.h"

@implementation PAFetchManager


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;

+ (instancetype)sharedFetchManager{
    
    static PAFetchManager *_sharedFetchManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFetchManager = [[PAFetchManager alloc] init];
    });
    
    return _sharedFetchManager;
}


-(void)manuallyChangeInstituion{
    //changes the insitution of the user to his home instition
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* instID = [defaults objectForKey:@"home_institution"];
    Institution* institution = [self fetchInstitutionForID:instID];
    [defaults setObject:institution.id forKey:@"institution_id"];
    
    [self switchInstitution];
}

-(void)switchInstitution{
    //takes care of instiution switching
   
    [self removeAllUnnecessaryPeers];
    [self removeAllObjectsOfType:@"Event"];
    [self removeAllObjectsOfType:@"Subscription"];
    [self removeAllObjectsOfType:@"Explore"];
    
    [[PASyncManager globalSyncManager] updateEventInfo];
    [[PASyncManager globalSyncManager] updateDiningInfo];
    [[PASyncManager globalSyncManager] updateSubscriptions];
    [[PASyncManager globalSyncManager] updateExploreInfoForViewController:nil];
    [[PASyncManager globalSyncManager] updatePeerInfo];
}

-(void)removeAllUnnecessaryPeers{
    //removes all peers that are not peers of the current institution or home institution
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* predicateArray = [[NSMutableArray alloc] init];
    if([defaults objectForKey:@"home_institution"]){
        NSPredicate* homePredicate = [NSPredicate predicateWithFormat:@"home_institution != %@", [defaults objectForKey:@"home_institution"]];
        [predicateArray addObject:homePredicate];
    }
    NSLog(@"don't delete peers from institution: %@", [defaults objectForKey:@"institution_id"]);
    NSPredicate* currentInstitutionPredicate = [NSPredicate predicateWithFormat:@"home_institution != %@", [defaults objectForKey:@"institution_id"]];
    [predicateArray addObject:currentInstitutionPredicate];
    
    NSPredicate* compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    
    [fetchRequest setPredicate:compoundPredicate];

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    for (NSManagedObject * object in mutableFetchResults) {
        [_managedObjectContext deleteObject:object];
    }
    NSError *saveError = nil;
    [_managedObjectContext save:&saveError];
}

-(Peer*)getPeerWithID:(NSNumber*)peerID{
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* moc = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"id";
    NSNumber *attributeValue = peerID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[moc executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    
    if([mutableFetchResults count]>0){
        return mutableFetchResults[0];
    }
    return nil;

}

-(void)logoutUser{
    [self setAllSubscriptionsFalseForCategory:@"athletic"];
    [self setAllSubscriptionsFalseForCategory:@"department"];
    [self setAllSubscriptionsFalseForCategory:@"club"];
    [self removeAllObjectsOfType:@"Circle"];
    [self removeAllObjectsOfType:@"Announcement"];
    [self removeAllObjectsOfType:@"Comment"];
    [self removeAllObjectsOfType:@"Peck"];
    [self removeAllObjectsOfType:@"Event"];
    [self removeAllObjectsOfType:@"Explore"];
    
    [[PASyncManager globalSyncManager] updatePeerInfo];
}

-(void)loginUser{
    
    
    
    // This method removes the peer from core data with id equal to the new logged in user's id.
    // It protects against logging in on a friends phone and being able to invite yourself to events and circles
    // The method then updates the peers (in order to load the now logged out user into core data)
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    Peer* oldUser = [self getPeerWithID:[defaults objectForKey:@"user_id"]];
    if(oldUser){
        [_managedObjectContext deleteObject:oldUser];
    }
    
    [self removeAllObjectsOfType:@"Explore"];
    [[PASyncManager globalSyncManager] updateExploreInfoForViewController:nil];
    [[PASyncManager globalSyncManager] updateDiningInfo];
    [[PASyncManager globalSyncManager] updatePecks];
    [[PASyncManager globalSyncManager] updateCircleInfo];
    //[[PASyncManager globalSyncManager] updatePeerInfo];
}

-(void)removeAllObjectsOfType:(NSString*)type{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * allObjects = [[NSFetchRequest alloc] init];
    [allObjects setEntity:[NSEntityDescription entityForName:type inManagedObjectContext:_managedObjectContext]];
    [allObjects setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * objects = [_managedObjectContext executeFetchRequest:allObjects error:&error];
    //error handling goes here
    for (NSManagedObject * object in objects) {
        [_managedObjectContext deleteObject:object];
    }
    NSError *saveError = nil;
    [_managedObjectContext save:&saveError];
}



-(void)removeCircle:(NSNumber*)circleID{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Circle" inManagedObjectContext:_managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id = %@", circleID];
    [fetchRequest setPredicate:predicate];
    
    NSError * error = nil;
    NSArray * circles = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Delete all circles fetched with the given id. This should only ever be one cirlce.
    for (NSManagedObject * circle in circles) {
        [_managedObjectContext deleteObject:circle];
    }
    NSError *saveError = nil;
    [_managedObjectContext save:&saveError];
}

-(void)removeAllEvents{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * allEvents = [[NSFetchRequest alloc] init];
    [allEvents setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext]];
    [allEvents setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * events = [_managedObjectContext executeFetchRequest:allEvents error:&error];
    //error handling goes here
    for (NSManagedObject * event in events) {
        [_managedObjectContext deleteObject:event];
    }
    NSError *saveError = nil;
    [_managedObjectContext save:&saveError];
}

-(NSMutableArray*)fetchSubscriptionsForCategory:(NSString*)category{
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:_managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category like %@",
                              category];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    return mutableFetchResults;
}

-(void)setAllSubscriptionsFalseForCategory:(NSString *)category{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:_managedObjectContext]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"category like %@",category];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    for(int i = 0; i<[mutableFetchResults count]; i++){
        Subscription* subscription = mutableFetchResults[i];
        subscription.subscribed = [NSNumber numberWithBool:NO];
    }
}

-(void)setSubscribedTrue:(NSNumber*)subID withCategory:(NSString *)category andSubscriptionID:(NSNumber*)subscriptionID{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:_managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@",
                              subID];
    NSPredicate* categoryPredicate = [NSPredicate predicateWithFormat:@"category like %@", category];
    
    NSArray* predicateArray = [NSArray arrayWithObjects:categoryPredicate, predicate, nil];
    NSPredicate* compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    
    [fetchRequest setPredicate:compoundPredicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if([mutableFetchResults count]>0){
        Subscription* tempSubscription = mutableFetchResults[0];
        tempSubscription.subscribed = [NSNumber numberWithBool:YES];
        tempSubscription.subscription_id = subscriptionID;
    }

}

-(Comment*)commentForID:(NSNumber*)commentID{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"id";
    NSNumber *attributeValue = commentID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    
    if([mutableFetchResults count]>0){
        Comment* comment = mutableFetchResults[0];
        return comment;
    }
    return nil;

}

-(id)getObject:(NSNumber *) newID withEntityType:(NSString*)entityType andType:(NSString*)type
{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *objects = [NSEntityDescription entityForName:entityType inManagedObjectContext:_managedObjectContext];
    [request setEntity:objects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", newID];
    NSMutableArray*predicateArray = [[NSMutableArray alloc] init];
    [predicateArray addObject:predicate];
    //[request setPredicate:predicate];
    
    if(type!=nil){
        NSPredicate* categoryPredicate = [NSPredicate predicateWithFormat:@"type like %@",type];
        [predicateArray addObject:categoryPredicate];
    }
    
    NSPredicate *compoundPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [request setPredicate:compoundPredicate];
    
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    //fetch events in order to check if the events we want to add already exist in core data
    
    if([mutableFetchResults count]>0){
        return mutableFetchResults[0];
    }
    else {
        return nil;
    }
}

-(void)deleteObject:(NSNumber *) newID withEntityType:(NSString*)entityType andCategory:(NSString*)category
{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *objects = [NSEntityDescription entityForName:entityType inManagedObjectContext:_managedObjectContext];
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
    
    if([mutableFetchResults count]>0){
        [_managedObjectContext deleteObject:mutableFetchResults[0]];
        NSError *saveError = nil;
        [_managedObjectContext save:&saveError];
    }
}

-(Event*)getEventWithID:(NSNumber*)eventID andType:(NSString*)type{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"id";
    NSNumber *attributeValue = eventID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    
    if([mutableFetchResults count]>0){
       Event* comment = mutableFetchResults[0];
        return comment;
    }
    return nil;

}

-(Institution*)fetchInstitutionForID:(NSNumber*)instID{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Institution" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id = %@", instID];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
    if ([array count]>0)
    {
       
        return array[0];
    }
    return nil;
}

@end
