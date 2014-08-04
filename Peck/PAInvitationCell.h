//
//  PAInvitationCell.h
//  Peck
//
//  Created by John Karabinos on 7/18/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAInvitationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *thumbnailViewTemplate;

@property (strong, nonatomic) UIView * thumbnailView;
@end
