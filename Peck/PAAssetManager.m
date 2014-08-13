//
//  PAAssetManager.m
//  Peck
//
//  Created by Jonas Luebbers on 7/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAAssetManager.h"

#define darkColor [UIColor colorWithRed:29/255.0 green:28/255.0 blue:36/255.0 alpha:1]
#define lightColor [UIColor colorWithRed:59/255.0 green:56/255.0 blue:71/255.0 alpha:1]

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

    }
    return self;
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
