//
//  PASubscriptionsHeader.m
//  Peck
//
//  Created by Aaron Taylor on 12/6/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASubscriptionsHeader.h"

@implementation PASubscriptionsHeader

- (void)prepareForReuse {
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    
    CGFloat lineWidth = 0.5f;
    CGContextSetLineWidth(ctx, lineWidth);
    
    // upper line
    CGContextMoveToPoint(ctx, 0, lineWidth * 0.5f);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, lineWidth * 0.5f);
    CGContextStrokePath(ctx);
    
    // bottom line
    CGFloat y = self.bounds.size.height;
    CGContextMoveToPoint(ctx, 0, y - lineWidth * 0.5f);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, y - lineWidth * 0.5f);
    CGContextStrokePath(ctx);

}

@end
