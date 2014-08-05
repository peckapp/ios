//
//  PANestedTableViewController.m
//  Peck
//
//  Created by Jonas Luebbers on 8/4/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PANestedTableViewController.h"

@interface PANestedTableViewController ()

@property (strong, nonatomic) NSMutableDictionary *detailViewControllers;
@property (strong, nonatomic) NSIndexPath *selectedCellIndexPath;

@end

@implementation PANestedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewControllers = [[NSMutableDictionary alloc] init];
}

- (UITableViewCell *)configureDetailViewControllerCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIViewController * newVC = [self viewControllerAtIndexPath:indexPath];
    
    [newVC willMoveToParentViewController:self];
    [newVC.view removeFromSuperview];
    [newVC removeFromParentViewController];
    [self addChildViewController:newVC];
    [cell addSubview:newVC.view];
    [newVC didMoveToParentViewController:self];
    
    NSLog(@"added new view controller");
    
    return cell;
}

- (BOOL)indexPathIsSelected:(NSIndexPath *)indexPath
{
    return self.selectedCellIndexPath != nil && self.selectedCellIndexPath.row == indexPath.row;
}

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

- (void)tableView:(UITableView *)tableView expandRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController * child = [self viewControllerAtIndexPath:indexPath];
    [child.view addSubview:self.backButton];
    child.view.userInteractionEnabled = YES;

    self.selectedCellIndexPath = indexPath;
    [tableView beginUpdates];
    [tableView endUpdates];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    tableView.scrollEnabled = NO;
}

- (void)tableView:(UITableView *)tableView compressRowAtSelectedIndexPathUserInteractionEnabled:(BOOL)interaction
{
    NSIndexPath * indexPath = self.selectedCellIndexPath;
    self.selectedCellIndexPath = nil;
    tableView.scrollEnabled = YES;
    [tableView beginUpdates];
    [tableView endUpdates];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

    UIViewController * child = [self viewControllerAtIndexPath:indexPath];
    child.view.userInteractionEnabled = interaction;
    [self.backButton removeFromSuperview];
}

@end
