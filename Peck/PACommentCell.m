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
#import "PAFetchManager.h"
#import "PAFriendProfileViewController.h"
#import "PAAthleticEventViewController.h"

@implementation PACommentCell

PAAssetManager * assetManager;

#define commentPlaceholder @"Add a comment..."

- (void)awakeFromNib
{

    assetManager = [PAAssetManager sharedManager];
    
    [self.commentTextView setEditable:NO];
    [self.commentTextView setScrollEnabled:NO];
    [self.commentTextView setText:commentPlaceholder];
    [self.commentTextView setTextColor:[UIColor lightGrayColor]];
    self.commentTextView.delegate=self;
    self.thumbnailViewTemplate.hidden = NO;
    self.thumbnailViewTemplate.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile)];
    tapRecognizer.cancelsTouchesInView = YES;
    [self.thumbnailViewTemplate addGestureRecognizer:tapRecognizer];
    self.thumbnailViewTemplate.userInteractionEnabled =YES;

    
    self.expanded=NO;
}

-(void)showProfile{
    NSLog(@"show the user's profile");
    Peer*peer = [[PAFetchManager sharedFetchManager] getObject:self.commentor_id withEntityType:@"Peer" andType:nil];
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [loginStoryboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    PAFriendProfileViewController*root = navController.viewControllers[0];
    root.peer=peer;
    if(self.parentCircleTableView){
        [self.parentCircleTableView presentViewController:navController animated:YES completion:nil];
    }else if(self.parentTableView){
         [self.parentTableView presentViewController:navController animated:YES completion:nil];
    }
}


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.commentTextView.textColor == [UIColor lightGrayColor]) {
        self.commentTextView.text = @"";
        self.commentTextView.textColor = [UIColor blackColor];
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
    if([self.parentTableView isKindOfClass:[PAEventInfoTableViewController class]]){
        category = @"simple";
    }else if([self.parentTableView isKindOfClass:[PAAthleticEventViewController class]]){
        category = @"athletic";
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

/*
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
        // [self.expandButton setTitle:@"Hide" forState:UIControlStateNormal];
    }
    else{
        if(self.parentTableView){
            PAEventInfoTableViewController *parent = (PAEventInfoTableViewController*)self.parentTableView;
            [parent compressTableViewCell:self];
        }else if(self.parentCircleTableView){
            PACirclesTableViewController *parent = (PACirclesTableViewController*)self.parentCircleTableView;
            [parent compressTableViewCell:self];
        }
        // [self.expandButton setTitle:@"More" forState:UIControlStateNormal];
    }
    self.expanded = !self.expanded;
}
 */


@end
