//
//  PAPeers.m
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPeers.h"
#import "PABST.h"
#import "PAAppDelegate.h"
#import "Peer.h"

@interface PAPeers(){
    
}

@end

@implementation PAPeers{
    

}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)peers {
    static PAPeers *_peers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _peers = [[PAPeers alloc] init];
    });
    
    return _peers;
}

-(id)init{
    
    
    self.peerTree = [[PABST alloc] init];
    
    [self addNewPeers];
    return self;
}

-(void)addNewPeers{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults =[[_managedObjectContext executeFetchRequest:fetchRequest error:&error]mutableCopy];
    
    for(int i=0; i<[mutableFetchResults count]; i++){
        Peer *tempPeer =mutableFetchResults[i];
        [self.peerTree addNode:self.peerTree withPeer: tempPeer];
    }
}


@end
