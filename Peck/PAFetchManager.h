//
//  PAFetchManager.h
//  Peck
//
//  Created by John Karabinos on 7/21/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"
#import "Comment.h"
#import "Institution.h"

@interface PAFetchManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+(instancetype)sharedFetchManager;

-(void)manuallyChangeInstituion;
//switches the institution to the user's home institution and then calls switch institution

-(void)switchInstitution;
//Takes care of necessary insitution switching things. Removes all subscriptions and events from core data and then loads them from the webservice with the new institution id

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

-(Comment*)commentForID:(NSNumber*)commentID;
//returns the comment with the corresponding ID from core data

-(id)getObject:(NSNumber *) newID withEntityType:(NSString*)entityType andType:(NSString*)type;
//returns the object with the given id, entity type, and type

-(void)deleteObject:(NSNumber *) newID withEntityType:(NSString*)entityType andCategory:(NSString*)category;

-(void)removeCircle:(NSNumber*)circleID;
//removes the circle for the given id

-(Institution*)fetchInstitutionForID:(NSNumber*)instID;

-(void)removeAllObjectsOfType:(NSString*)type;
@end
