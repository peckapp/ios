//
//  PAFeedCell.m
//  Peck
//
//  Created by Jonas Luebbers on 6/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFeedCell.h"

@implementation PAFeedCell
@synthesize messageTextView;

- (void)awakeFromNib
{
    // Initialization code
    [messageTextView setEditable:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
