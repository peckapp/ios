//
//  PAFeedCell.m
//  Peck
//
//  Created by Jonas Luebbers on 6/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAExploreCell.h"

@implementation PAExploreCell

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)attendEvent:(id)sender {
    NSLog(@"attend the event");
}
@end
