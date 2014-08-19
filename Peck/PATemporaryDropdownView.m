//
//  PATemporaryDropdownView.m
//  Peck
//
//  Created by Jonas Luebbers on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PATemporaryDropdownView.h"

#define primaryDelay 0.1
#define secondaryDelay 0.2
#define hideDelay 1.5

@interface PATemporaryDropdownView ()

@property (assign, nonatomic) NSInteger pendingHideCount;

@end

@implementation PATemporaryDropdownView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;

        self.hiddenView = [[UIView alloc] initWithFrame:CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height)];
        self.hiddenView.userInteractionEnabled = YES;
        [self addSubview:self.hiddenView];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:17.0];
        self.label.text = @"";
        self.label.alpha = 0;
        [self.hiddenView addSubview:self.label];
    }
    return self;
}

- (void)showHiddenView
{
    if (self.pendingHideCount <= 0) {
        [self animateIn];
    }
    self.pendingHideCount += 1;
    [self performSelector:@selector(hideHiddenView) withObject:self afterDelay:hideDelay];
}

- (void)hideHiddenView
{
    self.pendingHideCount -= 1;
    if (self.pendingHideCount <= 0) {
        [self animateOut];
    }
}

- (void)forceHiddenView
{
    if (self.pendingHideCount > 0) {
        self.pendingHideCount = 0;
        [self animateOut];
    }
}

- (void)animateIn
{
    [UIView animateWithDuration:0.2 delay:primaryDelay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.hiddenView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];

    [UIView animateWithDuration:0.3 delay:secondaryDelay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.label.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)animateOut
{
    [UIView animateWithDuration:0.2 delay:secondaryDelay - primaryDelay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.hiddenView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.label.alpha = 0;
                     }
                     completion:^(BOOL finished){
                     }];
}

@end
