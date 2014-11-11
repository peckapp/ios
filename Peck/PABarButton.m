//
//  PABarButton.m
//  Peck
//
//  Created by Aaron Taylor on 11/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PABarButton.h"
#import "PAAssetManager.h"

#define SUBTITLE_HEIGHT 10.0

@interface PABarButton ()

@end

@implementation PABarButton

//- (void)drawRect:(CGRect)rect {
//    if (self.selected) {
//        UIGraphicsBeginImageContextWithOptions (self.imageView.image.size, NO, [[UIScreen mainScreen] scale]);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetBlendMode(context, kCGBlendModeDifference);
//        [[UIColor lightGrayColor] setFill];
//        CGRect contectRect = [self contentRectForBounds:rect];
//        CGContextFillRect(context, contectRect);
//        
//        UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        self.imageView.image = coloredImage;
//        
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.imageView.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), 0.0f, frame.size.width, frame.size.height);
    self.imageView.frame = frame;
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.imageView setTintColor:self.tintColor];

    if (self.selected) {
        self.titleLabel.font = [UIFont systemFontOfSize:11.0];
    } else {
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
    }
    [self.titleLabel sizeToFit];
    frame = self.titleLabel.frame;
    frame = CGRectMake(truncf((self.bounds.size.width - frame.size.width) / 2), self.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
    self.titleLabel.frame = frame;
    self.titleLabel.textColor = self.tintColor;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    

}

@end
