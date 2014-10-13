//
//  PANestedInfoViewControllerPrivate.h
//  Peck
//
//  Created by Aaron Taylor on 10/12/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PANestedInfoViewController.h"

#define defaultCommentCellHeight 72

@class PACommentCell;

// private class extensions of the
@interface PANestedInfoViewController () {
    
}

// configures the view with the information from the detailItem
-(void)configureView;

-(void)configureCell:(PACommentCell *)cell atIndexPath: (NSIndexPath *)indexPath;

@property (nonatomic, retain) NSDateFormatter *formatter;

@property (assign, nonatomic) BOOL expanded;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIView *imagesView;

@property (strong, nonatomic) UIImageView *cleanImageView; // displayed when expanded
@property (strong, nonatomic) UIImageView *blurredImageView; // displayed when compressed

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *fullTitleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) UIImage *attendImage;
@property (strong, nonatomic) UIImage *nullAttendImage;

@property (strong, nonatomic) UIImageView *attendingIcon; // visible only if the event is being attended by the user
@property (strong, nonatomic) UIButton *attendButton;
@property (strong, nonatomic) UILabel *attendeesLabel;

@property (strong, nonatomic) UIView * keyboardAccessoryView;
@property (strong, nonatomic) UITextField * keyboardAccessory;
@property (strong, nonatomic) UIButton * postButton;

@property (strong, nonatomic) UITextView *textViewHelper;

- (void)registerForKeyboardNotifications;
- (void)deregisterFromKeyboardNotifications;

-(void) showSeparators;
-(void) hideSeparators;

@end
