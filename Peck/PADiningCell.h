//
//  PADiningCell.h
//  Peck
//
//  Created by John Karabinos on 7/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PADiningCell : UITableViewCell <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;

@property (weak, nonatomic) IBOutlet UITableView *menuItemsTableView;

@end
