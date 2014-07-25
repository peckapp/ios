//
//  PAEventCell.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAEventCell : UITableViewCell

// Overwrite UIView * background view as UIImageView
@property (strong, nonatomic) UIImageView * backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;

@end
