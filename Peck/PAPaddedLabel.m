//
//  PAPaddedLabel.m
//  Peck
//
//  Created by Aaron Taylor on 11/12/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPaddedLabel.h"

@implementation PAPaddedLabel

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

@end
