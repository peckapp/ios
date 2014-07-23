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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.profileButton = [[UIButton alloc] initWithFrame:self.bounds];
        [self.profileButton addTarget:self action:@selector(onProfileTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.profileButton setImage:[UIImage imageNamed:@"profile-placeholder"] forState:UIControlStateNormal];
        self.profileButton.layer.cornerRadius = self.profileButton.frame.size.width / 2;
        self.profileButton.clipsToBounds = YES;
        [self addSubview:self.profileButton];
    }
    return self;
}

- (void)onProfileTap:(id)sender
{
    
}

@end
