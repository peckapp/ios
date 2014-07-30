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

    }
    return self;
}

- (UIButton *)createThumbnailWithFrame:(CGRect)frame image:(UIImage *)image
{
    CGFloat size = 40;

    UIButton * button = [[UIButton alloc]initWithFrame:frame];

    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width / 2 - size / 2, frame.size.height / 2 - size / 2, size, size)];
    imageView.image = image;
    imageView.layer.cornerRadius = size / 2;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    [button addSubview:imageView];

    return button;
}

@end
