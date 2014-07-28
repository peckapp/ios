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

        self.imageView = [[UIImageView alloc] initWithFrame:subFrame];

        self.imageView.image = image;
        self.imageView.layer.cornerRadius = subFrame.size.width / 2;
        self.imageView.clipsToBounds = YES;

        self.imageView.userInteractionEnabled=NO;
        [button addSubview:self.imageView];
        [self addSubview:button];
    }
    return self;
}

- (void)onProfileTap:(id)sender
{
    
}

@end
