//
//  PAUtils.h
//  Peck
//
//  Created by Aaron Taylor on 8/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#ifndef Peck_PAUtils_h
#define Peck_PAUtils_h

// device identifying values
#define deviceVendorIdentifier [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define storedPushToken [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]

// NSUserDefaults keys
#define logged_in_key @"logged_in"
#define institution_id_key @"institution_id"

// common boilerplate methods calls
#define REGISTER_PUSH_NOTIFICATIONS [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge]

#endif
