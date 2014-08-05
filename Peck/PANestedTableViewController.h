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

- (UITableViewCell *)configureDetailViewControllerCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)indexPathIsSelected:(NSIndexPath *)indexPath;

- (UIViewController *)viewControllerAtIndexPath:(NSIndexPath *)indexPath;
- (void)setViewController:(UIViewController *)viewController atIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView compressRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView expandRowAtIndexPath:(NSIndexPath *)indexPath;

@end
