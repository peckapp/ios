//
//  PAFilter.m
//  Peck
//
//  Created by Aaron Taylor on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFilter.h"

@interface PAFilter() {
    
}

@property (nonatomic, getter=isActive) BOOL active;

@end

@implementation PAFilter

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"created frame for filter");
        [self.layer setFrame:frame];
    }
    return self;
}

// if the touch is on the filter ui element, make the web appear
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    [self setNeedsDisplay]; // let the system know to update the view, probably want to do this with animation instead
}

// if the web is active, handle the touches
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isActive]) {
        // check which web item is being selected, animate as necessary
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isActive]) {
        // call methods in superview to update table view cells accordingly
    }
    self.active = false;
}

@end
