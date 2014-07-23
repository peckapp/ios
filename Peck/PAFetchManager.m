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
    [self removeAllCircles];
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
    
    [[PASyncManager globalSyncManager] updatePeerInfo];
}

-(void)removeAllCircles{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * allCircles = [[NSFetchRequest alloc] init];
    [allCircles setEntity:[NSEntityDescription entityForName:@"Circle" inManagedObjectContext:_managedObjectContext]];
    [allCircles setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * circles = [_managedObjectContext executeFetchRequest:allCircles error:&error];
    //error handling goes here
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
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    return mutableFetchResults;
}

-(void)setSubscribedTrue:(NSNumber*)subID withCategory:(NSString *)category{
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
    }

}

@end
