//
//  PASyncManager.h
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Circle.h"
#import "Event.h"
#import "PADiningPlacesTableViewController.h"

@interface PASyncManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)globalSyncManager;

// methods for anonymous user creation and subsqquent registration

-(void)logoutUser;

-(void)createAnonymousUserHelper;
//calls create anonymous user with a completetion block that has components more easily accessed from within the sync manager

// sends the device token to the server and performs operations based on the result
-(void)sendUDIDForInitViewController:(UIViewController*)initViewController;
// sends post request to server with institution_id and stores response user_id in NSUserDefaults
-(void)ceateAnonymousUser:(void (^)(BOOL))callbackBlock;
// sends post request to the server completing the user's other info after the registration process is triggered
-(void)updateUserWithInfo:(NSDictionary*)userInfo withImage:(NSData*)imageData;
// authenticates the user and updates the authentication token returned from the server
- (void)authenticateUserWithInfo:(NSDictionary*)userInfo forViewController:(UITableViewController*)controller direction:(BOOL)goToHomepage;
// sends patch request to the server when the registration process is complete
-(void)registerUserWithInfo:(NSDictionary*)userInfo;

-(void)changePassword:(NSDictionary*)passwordInfo forViewController:(UIViewController*)controller;

// like actions
-(void)likeComment:(NSInteger)commentID from:(NSString*)comment_from withCategory:(NSString*)category;
-(void)unlikeComment:(NSInteger)commentID from:(NSString*)comment_from withCategory:(NSString*)category;

//attend actions
-(void)attendEvent:(NSDictionary*) attendee forViewController:(UIViewController*)controller;
-(void)unattendEvent:(NSDictionary*) attendee forViewController:(UIViewController*)controller;
;
// methods for syncing institutions for the configuration phase
-(void)updateAvailableInstitutionsWithCallback:(void(^)(BOOL sucess))callbackBlock;

//announcement actions
-(void)postAnnouncement:(NSDictionary*)dictionary withImage:(NSData*)imageData;
-(void)updateAnnouncement:(NSNumber*)announcementID withDictionary:(NSDictionary*)dictionary withImage:(NSData*)imageData;

// methods for updating events
-(void)updateEventInfo;
-(void)postEvent:(NSDictionary *) dictionary withImage:(NSData*)imageDate;
-(void)deleteEvent:(NSNumber*)eventID;
-(void)updateEvent:(NSNumber*)eventID withDictionary:(NSDictionary*)dictionary withImage:(NSData*)imageData;

// methods for updating dining
-(void)updateDiningInfo;
-(void)updateDiningPlaces:(DiningPeriod*)diningPeriod forController:(PADiningPlacesTableViewController*)viewController;
//-(void)getDiningPeriodForPlace:(DiningPlace*)diningPlace andOpportunity:(Event*)diningOpportunity withViewController:(PADiningPlacesTableViewController*)viewController forNumberAdded:(NSInteger)numberAdded;
-(void)updateDiningPeriods:(Event*)diningOpportunity forViewController:(PADiningPlacesTableViewController*)viewController;
-(void)updateMenuItemsForOpportunity:(Event*)diningOpportunity andPlace:(DiningPlace*)diningPlace;

// methods for updating circles
-(void)postCircle: (NSDictionary *) dictionary;
-(void)leaveCircle: (NSDictionary*) dictionary;
-(void)postCircleMember:(Peer*)newMember withDictionary:(NSDictionary *) dictionary forCircle:(Circle*)circle withSender:(id)sender;
-(void)updateCircleInfo;
-(void)acceptCircleInvite:(NSInteger)circleMemberID withPeckID:(NSNumber*)peckID;
-(void)deleteCircleMember:(NSInteger)circleMemberID withPeckID:(NSNumber*)peckID;

//methods for updating pecks
-(void)postPeck:(NSDictionary*)dictionary;
-(void)updatePecks;

//methods for comments
-(void)postComment:(NSDictionary *)dictionary;
-(void)updateCommentsFrom: (NSString *)comment_from withCategory:(NSString *)category;

-(void)updatePeerInfo;

-(void)updateExploreInfo;

//methods for subscriptions
-(void)updateSubscriptions;
-(void)postSubscriptions:(NSArray*)array;
-(void)deleteSubscriptions:(NSArray*)array;

// -(BOOL)objectExists:(NSNumber *)newID withType: (NSString *) type;

@end
