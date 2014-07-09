//
//  PACommentCell.h
//  Peck
//
//  Created by John Karabinos on 7/3/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PAEventInfoTableViewController.h"

@interface PACommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property BOOL expanded;
@property (weak, nonatomic) UITableViewController *parentTableView;
@property (weak, nonatomic) UITableViewController *parentCircleTableView;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

- (IBAction)postButton:(id)sender;

- (IBAction)expandButton:(id)sender;

@end
