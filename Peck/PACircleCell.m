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
#import "PAAppDelegate.h"
#import "Circle.h"

@implementation PACircleCell
@synthesize scrollView;
@synthesize circleTitle;
@synthesize members = _members;
bool loadedImages;
- (void)awakeFromNib
{
    // Initialization code
    
    [scrollView setScrollEnabled:YES];
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector (selectProfile:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [scrollView addGestureRecognizer:tapRecognizer];
    scrollView.userInteractionEnabled =YES;
    loadedImages=NO;
    
    
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

-(void)addImages{
    //TODO: fix this code so that reloading the table view does not reallocate
    if(!loadedImages){
        for(int i = 0; i < _members; i++){
            NSLog(@"allocating image");
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80*i, 0, 55, 44)];
            imageView.image = [UIImage imageNamed:@"Silhouette.png"];
            //use tag and i to get the correct image
            [scrollView addSubview:imageView];
        }
    }loadedImages=YES;
}


@end





