//
//  PABarButton.m
//  Peck
//
//  Created by Aaron Taylor on 11/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PABarButton.h"

#define SUBTITLE_HEIGHT 10.0

@interface PABarButton ()

@end

@implementation PABarButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.imageView.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), 0.0f, frame.size.width, frame.size.height);
    self.imageView.frame = frame;
    
    frame = self.titleLabel.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), self.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
    self.titleLabel.frame = frame;
}

@end
