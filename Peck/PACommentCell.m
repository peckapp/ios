//
//  PACommentCell.m
//  Peck
//
//  Created by John Karabinos on 7/3/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACommentCell.h"
#import "PAEventInfoTableViewController.h"
#import "PASyncManager.h"
#import "PACirclesTableViewController.h"

@implementation PACommentCell

@synthesize nameLabel, postTimeLabel, profilePicture, commentTextView, expandButton;

- (void)awakeFromNib
{
    
    [commentTextView setEditable:NO];
    [commentTextView setScrollEnabled:NO];
    
    _expanded=NO;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)postButton:(id)sender {
    NSLog(@"post (in cell)");
    if(self.parentTableView){
        PAEventInfoTableViewController *parent = (PAEventInfoTableViewController*)self.parentTableView;
        [parent postComment:self];
    }
    else if(self.parentCircleTableView){
        PACirclesTableViewController *parent = (PACirclesTableViewController*)self.parentCircleTableView;
        [parent postComment:self];
    }

}

- (IBAction)expandButton:(id)sender {
    NSLog(@"expand the cell");
    if(self.expanded==NO){
        if(self.parentTableView){
            PAEventInfoTableViewController *parent = (PAEventInfoTableViewController*)self.parentTableView;
            [parent expandTableViewCell:self];
        }else if(self.parentCircleTableView){
            PACirclesTableViewController *parent = (PACirclesTableViewController*)self.parentCircleTableView;
            [parent expandTableViewCell:self];
        }
        [self.expandButton setTitle:@"Hide" forState:UIControlStateNormal];
    }
    else{
        if(self.parentTableView){
            PAEventInfoTableViewController *parent = (PAEventInfoTableViewController*)self.parentTableView;
            [parent compressTableViewCell:self];
        }else if(self.parentCircleTableView){
            PACirclesTableViewController *parent = (PACirclesTableViewController*)self.parentCircleTableView;
            [parent compressTableViewCell:self];
        }
        [self.expandButton setTitle:@"More" forState:UIControlStateNormal];
    }
    self.expanded = !self.expanded;
}


@end
