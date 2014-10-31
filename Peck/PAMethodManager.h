//
//  PAMethodManager.h
//  Peck
//
//  Created by John Karabinos on 8/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface PAMethodManager : NSObject <UIAlertViewDelegate>
@property UIViewController* sender;

+ (instancetype)sharedMethodManager;

// alerts that may need to be displayed throughout the app
-(void)showRegisterAlert:(NSString*)message forViewController:(UIViewController*)sender;
-(void)showInstitutionAlert:(void (^)(void))callbackBlock;
-(void)showUnauthorizedAlertWithCallbackBlock:(void (^)(void))callbackBlock;
-(void)showNoInternetAlertWithTitle:(NSString*)title AndMessage:(NSString*)message;
-(void)showNoInternetAlertWithMessage:(NSString*)message;
-(void)showNoInternetAlert;

-(UIImageView*)imageForPeer:(Peer*)peer;
-(void)postInfoToFacebook:(NSDictionary*)eventInfo withImage:(NSData*)imageData;

-(void)handleResetLink:(NSMutableDictionary*)urlInfo;

// handles all necessary logout actions, calling relevant fetch and sync manager methods, clearing FBSession, clearing NSUserDefaults, and creating a new anonymous user
-(void)logoutUserCompletely;

-(void)resetTutorialBooleans;
-(void)showTutorialAlertWithTitle:(NSString *)title andMessage:(NSString*)message;

-(BOOL)serverIsReachable;

@end
