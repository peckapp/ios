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

// methods for anonymous user creation and subsqquent registration
// sends post request to server with institution_id and stores response user_id in NSUserDefaults
-(void)ceateAnonymousUser;
// sends post request to the server completing the user's other info after the registration process is triggered
-(void)updateUserWithInfo:(NSDictionary*)userInfo;
// authenticates the user and updates the authentication token returned from the server
- (void)authenticateUserWithInfo:(NSDictionary*)userInfo;

// methods for syncing institutions for the configuration phase
-(void)updateAvailableInstitutionsWithCallback:(void(^)(BOOL sucess))callbackBlock;

// methods for updating the locally stored events
-(void)updateEventInfo;
-(void)postEvent:(NSDictionary *) dictionary;
-(void)deleteEvent:(NSNumber*)eventID;

// methods for updating circles
-(void)postCircle: (NSDictionary *) dictionary withMembers:(NSArray*)members;
-(void)updateCircleInfo;

//methods for comments
-(void)postComment:(NSDictionary *)dictionary;
-(void)updateCommentsFrom: (NSString *)comment_from withCategory:(NSString *)category;

-(void)updatePeerInfo;

-(void)updateExploreInfo;
-(BOOL)objectExists:(NSNumber *)newID withType: (NSString *) type;
@end
