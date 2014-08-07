//
//  PAMethodManager.h
//  Peck
//
//  Created by John Karabinos on 8/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAMethodManager : NSObject <UIAlertViewDelegate>
@property UIViewController* sender;

+ (instancetype)sharedMethodManager;

-(void)showRegisterAlert:(NSString*)message forViewController:(UIViewController*)sender;

@end
