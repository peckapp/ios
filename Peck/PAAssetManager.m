//
//  PAAssetManager.m
//  Peck
//
//  Created by Jonas Luebbers on 7/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAAssetManager.h"

@implementation PAAssetManager

+ (id)sharedManager {
    static PAAssetManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init {
    if (self = [super init]) {

        self.eventPlaceholder = [UIImage imageNamed:@"event-placeholder"];
        self.imagePlaceholder = [UIImage imageNamed:@"image-placeholder"];
        self.profilePlaceholder = [UIImage imageNamed:@"profile-placeholder"];
        self.horizontalShadow = [[UIImage imageNamed:@"drop-shadow-horizontal"]stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        self.unavailableColor = [UIColor colorWithHue:1 saturation:0 brightness:.85 alpha:1];
        
        
        CGSize size = CGSizeMake(200, 200);
        self.greyBackground = [self imageWithColor:[UIColor whiteColor] andSize:size];

    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImageView *)createThumbnailWithFrame:(CGRect)frame imageView:(UIImageView *)imageView
{
    CGFloat size = 40;

    //UIButton * button = [[UIButton alloc]initWithFrame:frame];

    imageView.frame = CGRectMake(frame.size.width / 2 - size / 2, frame.size.height / 2 - size / 2, size, size);
    imageView.layer.cornerRadius = size / 2;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    //[button addSubview:imageView];

    return imageView;
}


-(UIColor*)getUnavailableColor{
    return self.unavailableColor;
}
@end
