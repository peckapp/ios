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
// tutorials
#define first_launch @"first_launch"
#define DID_FIRST_LAUNCH [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:first_launch]
#define homepage_tutorial @"should_show_homepage_tutorial"
#define SHOW_HOMEPAGE_TUTORIAL [[NSUserDefaults standardUserDefaults] objectForKey:homepage_tutorial]
#define DID_SHOW_HOMEPAGE_TUTORIAL [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:homepage_tutorial]
#define dropdown_tutorial @"should_show_dropdown_tutorial"
#define SHOW_DROPDOWN_TUTORIAL [[NSUserDefaults standardUserDefaults] objectForKey:dropdown_tutorial]
#define DID_SHOW_DROPDOWN_TUTORIAL [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:dropdown_tutorial]

// common boilerplate methods calls
#define REGISTER_PUSH_NOTIFICATIONS [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge]

#endif
