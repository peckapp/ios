//
//  PASyncManager.h
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PASyncManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
+ (instancetype)globalSyncManager;
-(void)updateEventInfo;
-(void)postEvent:(NSDictionary *) dictionary;
-(void)deleteEvent:(NSNumber*)eventID;
-(void)postCircle: (NSDictionary *) dictionary withMembers:(NSArray*)members;
-(void)updateCircleInfo;
-(void)setUser;
-(void)updatePeerInfo;
@end
