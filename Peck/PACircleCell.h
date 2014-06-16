//
//  PACircleCellTableViewCell.h
//  Peck
//
//  Created by John Karabinos on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PACircleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *circleTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
