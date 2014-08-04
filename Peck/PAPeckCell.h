//
//  PAPeckCell.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAPeckCell : UITableViewCell

@property (strong, nonatomic) UIView * profileThumbnail;
@property (weak, nonatomic) IBOutlet UIView *profileTemplateView;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@property (strong,nonatomic) NSNumber* invited_by;
@property (strong, nonatomic) NSNumber* peckID;
@property (nonatomic) NSInteger invitation_id;

@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@property (weak, nonatomic) NSString* notification_type;

@property BOOL interactedWith;

- (IBAction)acceptInviteButton:(id)sender;
- (IBAction)declineInviteButton:(id)sender;

@end
