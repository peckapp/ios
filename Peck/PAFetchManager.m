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


@end
