//
//  PAPeckCell.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPeckCell.h"
#import "PAProfileThumbnailView.h"

@implementation PAPeckCell

- (void)awakeFromNib
{
    PAProfileThumbnailView * profileThumbnail = [[PAProfileThumbnailView alloc] initWithFrame:self.profileTemplateView.frame subFrame:self.profileTemplateSubview.frame image:[UIImage imageNamed:@"profile-placeholder"]];
    [self addSubview:profileThumbnail];
    self.profileTemplateView.hidden = true;
    self.profileTemplateSubview.hidden = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
