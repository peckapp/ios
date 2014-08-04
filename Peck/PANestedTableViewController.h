//
//  PANestedTableViewController.h
//  Peck
//
//  Created by Jonas Luebbers on 8/4/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PANestedTableViewController : UIViewController

@property (strong, nonatomic) UITableView * tableView;

- (UITableViewCell *)configureDetailViewControllerCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
