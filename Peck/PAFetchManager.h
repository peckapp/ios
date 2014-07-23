//
//  PAFetchManager.h
//  Peck
//
//  Created by John Karabinos on 7/21/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface PAFetchManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+(instancetype)sharedFetchManager;

-(Peer*)getPeerWithID:(NSNumber*)peerID;
-(void)logoutUser;
-(void)loginUser;
-(NSMutableArray*)fetchSubscriptionsForCategory:(NSString*)category;
-(void)setSubscribedTrue:(NSNumber*)subID withCategory:(NSString*)category;
@end
