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
#import "PACircleCell.h"
#import "PAAssetManager.h"

@implementation PACommentCell

@synthesize nameLabel, postTimeLabel, profilePicture, commentTextView, expandButton;

PAAssetManager * assetManager;

#define commentPlaceholder @"add a comment"

- (void)awakeFromNib
{

    assetManager = [PAAssetManager sharedManager];
    
    [commentTextView setEditable:NO];
    [commentTextView setScrollEnabled:NO];
    //commentTextView.frame= CGRectMake(98, 34, 222, 85);
    [commentTextView setText:commentPlaceholder];
    [commentTextView setTextColor:[UIColor lightGrayColor]];
    commentTextView.delegate=self;
    
    _expanded=NO;
    // Initialization code

    UIView * profileThumbnail = [assetManager createThumbnailWithFrame:CGRectMake(0, 0, 50, 50) image:[assetManager profilePlaceholder]];
    [self addSubview:profileThumbnail];
}



- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (commentTextView.textColor == [UIColor lightGrayColor]) {
        commentTextView.text = @"";
        commentTextView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(self.parentTableView){
        PAEventInfoTableViewController* parent = (PAEventInfoTableViewController*) self.parentTableView;
        parent.commentText = textView.text;
    }else if(self.parentCell){
        PACircleCell* parent = (PACircleCell*)self.parentCell;
        parent.commentText = textView.text;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
                     
    // Configure the view for the selected state
}

- (IBAction)likeButton:(id)sender {
    NSString*category = @"";
    if(self.parentTableView){
        category = @"simple";
    }
    else if(self.parentCell){
        category = @"circles";
    }
    if([self.likeButton.titleLabel.text isEqualToString:@"Like"]){
        [[PASyncManager globalSyncManager] likeComment:self.commentIntegerID from:self.comment_from withCategory:category];
    }else{
        [[PASyncManager globalSyncManager] unlikeComment:self.commentIntegerID from:self.comment_from withCategory:category];
        }
    
        
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
