//
//  PAFilter.h
//  Peck
//
//  Created by Aaron Taylor on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// explicit types for each possible mode of presentation 
typedef enum {
    PAFilterHomeMode,
    PAFilterExploreMode
} PAFilterMode;

@interface PAFilter : UIView

// whether or not the filter is presented on the screen
@property (nonatomic) BOOL presented;

// designated factory for the filter. use this for instantiation
+(instancetype)filter;

// causes the filter element to drop below the screen
- (void)dismissDownward;

// causes the filter element to rise into the screen with the specified mode
- (void)presentUpwardForMode:(PAFilterMode)mode;

@end
