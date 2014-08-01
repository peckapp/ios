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
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
