//
//  PANestedTableViewController.h
//  Peck
//
//  Created by Jonas Luebbers on 8/4/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PANestedTableViewController : UIViewController

@property (strong, nonatomic) UIButton * backButton;
@property (strong, nonatomic) NSIndexPath *selectedCellIndexPath;

- (UITableViewCell *)configureDetailViewControllerCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)indexPathIsSelected:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView expandRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)tableView:(UITableView *)tableView compressRowAtSelectedIndexPathAnimated:(BOOL)animated;
@end
