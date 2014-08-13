//
//  PACommentCell.h
//  Peck
//
//  Created by John Karabinos on 7/3/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PAEventInfoTableViewController.h"
#import "Comment.h"

@interface PACommentCell : UITableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIView *thumbnailViewTemplate;

@property (strong, nonatomic) UIView * thumbnailView;

@property BOOL expanded;

@property (weak, nonatomic) UITableViewController *parentTableView;
@property (weak, nonatomic) UITableViewController *parentCircleTableView;

@property (weak, nonatomic) UITableViewCell *parentCell;

@property (weak, nonatomic) NSNumber* commentID;
@property (nonatomic) NSInteger commentIntegerID;
@property (strong, nonatomic) NSString* comment_from;

@property (weak, nonatomic) NSNumber* commentor_id;
- (IBAction)likeButton:(id)sender;
@end
