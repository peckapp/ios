//
//  PAFeedCell.h
//  Peck
//
//  Created by Jonas Luebbers on 6/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAExploreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

//@property (weak, nonatomic) NSNumber* explore

- (IBAction)attendEvent:(id)sender;

@end
