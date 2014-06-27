//
//  PAPeers.h
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PABST.h"

@interface PAPeers : NSObject
+(instancetype)peers;
@property (atomic, retain) PABST * peerTree;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
