//
//  PAProfileThumbnailView.m
//  Peck
//
//  Created by Jonas Luebbers on 7/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAProfileThumbnailView.h"

@interface PAProfileThumbnailView ()

@property (strong, nonatomic) UIButton * profileButton;
- (void)onProfileTap:(id)sender;

@end

@implementation PAProfileThumbnailView

- (id)initWithFrame:(CGRect)frame subFrame:(CGRect)subFrame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {

        UIButton * button = [[UIButton alloc]initWithFrame:frame];
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:subFrame];

        imageView.image = image;
        imageView.layer.cornerRadius = subFrame.size.width / 2;
        imageView.clipsToBounds = YES;

        imageView.userInteractionEnabled=NO;
        [button addSubview:imageView];
        [self addSubview:button];
    }
    return self;
}

- (void)onProfileTap:(id)sender
{
    
}

@end
