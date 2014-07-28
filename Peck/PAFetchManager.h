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
//returns the peer from core data with the given id

-(void)logoutUser;
//performs a series of tasks necessary when the user is logged out

-(void)loginUser;
//performs a series of tasks necessary when the user is logged in

-(NSMutableArray*)fetchSubscriptionsForCategory:(NSString*)category;
//returns an array of all the subscriptions for a given category

-(void)setSubscribedTrue:(NSNumber*)subID withCategory:(NSString*)category andSubscriptionID:(NSNumber*)subscriptionID;
//sets a specific subscription.subscribed to true

-(void)setAllSubscriptionsFalseForCategory:(NSString*)category;
//Sets all of the subscriptions for the given category in core data to have a subscribed of false. This will happen every time the subscriptions are updated.
@end
