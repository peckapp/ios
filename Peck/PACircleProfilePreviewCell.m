//
//  PACircleProfilePreviewCell.m
//  Peck
//
//  Created by Jonas Luebbers on 7/25/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACircleProfilePreviewCell.h"

@implementation PACircleProfilePreviewCell

- (void)awakeFromNib
{
    self.profileThumbnail = [[PAProfileThumbnailView alloc] initWithFrame:self.frame subFrame:self.profileTemplateSubview.frame image:[UIImage imageNamed:@"profile-placeholder"]];
    [self addSubview:self.profileThumbnail];
    self.profileTemplateSubview.hidden = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
