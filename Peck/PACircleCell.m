//
//  PACircleCellTableViewCell.m
//  Peck
//
//  Created by John Karabinos on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACircleCell.h"
#import "PACirclesTableViewController.h"
#import "PAFriendProfileViewController.h"

@implementation PACircleCell
@synthesize scrollView;
@synthesize circleTitle;

- (void)awakeFromNib
{
    // Initialization code
    
    //TODO: replace 500 with a constant times the number of people in the circle
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 500, self.frame.size.height);
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(500, self.frame.origin.y)];
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (selectProfile:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [scrollView addGestureRecognizer:tapRecognizer];
    scrollView.userInteractionEnabled =YES;
    
    //TODO: replace 4 with the number of people in the circle
    for(int i = 0; i < 4; i++){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80*i, 0, 55, 44)];
        imageView.image = [UIImage imageNamed:@"Silhouette.png"];
        [scrollView addSubview:imageView];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)selectProfile: (UIGestureRecognizer*) sender{
    CGPoint tapPoint = [sender locationInView:scrollView];
    NSLog(@"cell: %i, x location: %f", self.tag, tapPoint.x);
    [_delegate Profile:2];

    //get the cell and the picture that has been selected and open that profile
}




@end





