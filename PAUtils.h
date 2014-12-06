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

// device information
#define IS_IOS6_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
#define IS_IOS7_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
#define IS_IOS8_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

// UI sizing values
#define TEMPORARY_HEADER_HEIGHT 44
#define SHOW_HEADER_DEPTH 50

// NSUserDefaults keys
#define logged_in_key @"logged_in"
#define institution_id_key @"institution_id"

// TUTORIALS
// first launch
#define first_launch @"first_launch"
#define DID_FIRST_LAUNCH [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:first_launch]
// homepage
#define homepage_tutorial @"should_show_homepage_tutorial"
#define SHOW_HOMEPAGE_TUTORIAL [[NSUserDefaults standardUserDefaults] objectForKey:homepage_tutorial]
#define DID_SHOW_HOMEPAGE_TUTORIAL [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:homepage_tutorial]
// dropdown
#define dropdown_tutorial @"should_show_dropdown_tutorial"
#define SHOW_DROPDOWN_TUTORIAL [[NSUserDefaults standardUserDefaults] objectForKey:dropdown_tutorial]
#define DID_SHOW_DROPDOWN_TUTORIAL [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:dropdown_tutorial]
// event post
#define post_tutorial @"should_show_post_tutorial"
#define SHOW_POST_TUTORIAL [[NSUserDefaults standardUserDefaults] objectForKey:post_tutorial]
#define DID_SHOW_POST_TUTORIAL [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:post_tutorial]
// attending an explore event
#define attend_tutorial @"should_show_attend_tutorial"
#define SHOW_ATTEND_TUTORIAL [[NSUserDefaults standardUserDefaults] objectForKey:attend_tutorial]
#define DID_SHOW_ATTEND_TUTORIAL [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:attend_tutorial]


// modes for view controllers to adapt to
typedef NS_ENUM(NSInteger, PAViewControllerMode) {
    PAViewControllerModeDefault,
    PAViewControllerModeInitializing,
};

// common boilerplate methods calls

#define REGISTER_PUSH_NOTIFICATIONS [[UIApplication sharedApplication] registerForRemoteNotifications]; \
                                    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |UIUserNotificationTypeSound categories:nil]];


#endif
