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

-(void)showRegisterAlert:(NSString*)message forViewController:(UIViewController*)sender;
-(UIImageView*)imageForPeer:(Peer*)peer;
-(void)postInfoToFacebook:(NSDictionary*)eventInfo withImage:(NSData*)imageDat; 
@end
