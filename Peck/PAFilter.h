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
} PAFilterType;

// types for each filtermode
typedef enum {
    PAFilterStandardMode,
    PAFilterDiningMode,
    PAFilterSubscribedMode,
    PAFilterInvitedMode
} PAFilterMode;

@protocol PAFilterDelegate;

@interface PAFilter : UIView

// whether or not the filter is presented on the screen
@property (nonatomic) BOOL presented;

@property (nonatomic, weak) id<PAFilterDelegate> delegate;

// designated factory for the filter. use this for instantiation
+(instancetype)filter;

// sets the frame based on its superview after it has been added to that view
- (void)setFrameBasedOnSuperview;

// causes the filter element to drop below the screen
- (void)dismissDownward;

// causes the filter element to rise into the screen with the specified mode
- (void)presentUpwardForMode:(PAFilterType)mode;

@end


@protocol PAFilterDelegate

// background gradient animation triggers, duration is identical to the animation of the filter itself
- (void)shadeBackgroundViewOverDuration:(float)duration;
- (void)unshadeBackgroundViewOverDuration:(float)duration;

// trigger changes in the filtered state of the home view controller
- (BOOL)requestFilterMode:(PAFilterMode)mode;

@end
