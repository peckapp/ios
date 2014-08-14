//
//  PANestedTableViewController.m
//  Peck
//
//  Created by Jonas Luebbers on 8/4/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PANestedTableViewController.h"
#import "PANestedTableViewCell.h"

@interface PANestedTableViewController ()

@end

@implementation PANestedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UITableViewCell *)configureDetailViewControllerCell:(PANestedTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    /*
    UIViewController * newVC = cell.viewController;
    [cell.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    
    NSLog(@"number of subviews: %lu", (unsigned long)[cell.subviews count]);
    
    UIView* view = [cell viewWithTag:3];
    if(view){
        [view removeFromSuperview];
        
    }
    
    
    [newVC willMoveToParentViewController:self];
    [newVC.view removeFromSuperview];
    [newVC removeFromParentViewController];

    [self addChildViewController:newVC];
    newVC.view.tag=3;
    [cell addSubview:newVC.view];
    [newVC didMoveToParentViewController:self];
    
    NSLog(@"added new view controller");
    */

    return cell;
}

- (BOOL)indexPathIsSelected:(NSIndexPath *)indexPath
{
    return self.selectedCellIndexPath != nil && self.selectedCellIndexPath.row == indexPath.row;
}

/*
- (UIViewController *)viewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [NSString stringWithFormat:@"%d-%d", (int)indexPath.section, (int)indexPath.row];
    NSLog(@"returning view controller for key: %@", key);
    return [self.detailViewControllers objectForKey:key];
}

- (void)setViewController:(UIViewController *)viewController atIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [NSString stringWithFormat:@"%d-%d", (int)indexPath.section, (int)indexPath.row];
    NSLog(@"set view controller for key: %@", key);
    [self.detailViewControllers setObject:viewController forKey:key];
}
 */

- (void)tableView:(UITableView *)tableView expandRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    self.selectedCellIndexPath = indexPath;
    [tableView beginUpdates];
    [tableView endUpdates];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    tableView.scrollEnabled = NO;
}

- (void)tableView:(UITableView *)tableView compressRowAtSelectedIndexPathAnimated:(BOOL)animated
{
    NSIndexPath * indexPath = self.selectedCellIndexPath;
    self.selectedCellIndexPath = nil;
    tableView.scrollEnabled = YES;
    [tableView beginUpdates];
    [tableView endUpdates];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];

    [self.backButton removeFromSuperview];
}

@end
