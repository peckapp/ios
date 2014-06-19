//
//  PAEventCell.h
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAEventCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *eventPhoto;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;

@end
