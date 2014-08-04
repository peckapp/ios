//
//  PANestedTableViewController.m
//  Peck
//
//  Created by Jonas Luebbers on 8/4/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PANestedTableViewController.h"

@interface PANestedTableViewController ()

@property (strong,nonatomic) NSMutableArray * detailViewControllers;
@property (strong,nonatomic) NSIndexPath * selectedCellIndexPath;
@property (strong,nonatomic) UIButton * backButton;

@end

@implementation PANestedTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(11, 11, 22, 22)];
    [self.backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.backgroundColor = [UIColor lightTextColor];
}

- (void)backButton:(id)sender
{
    NSIndexPath * indexPath = self.selectedCellIndexPath;
    self.selectedCellIndexPath = nil;
    self.tableView.scrollEnabled = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    // [self.tableView reloadData];

    [self.backButton removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.detailViewControllers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectedCellIndexPath != nil && self.selectedCellIndexPath.row == indexPath.row) {
        return self.view.frame.size.height;
    }
    return 44.0;
}

- (UITableViewCell *)configureDetailViewControllerCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (self.detailViewControllers.count > 0) {
        UIViewController * newVC = self.detailViewControllers[indexPath.row];

        [newVC willMoveToParentViewController:self];
        [newVC.view removeFromSuperview];
        [newVC removeFromParentViewController];
        [self addChildViewController:newVC];
        [cell addSubview:newVC.view];
        [newVC didMoveToParentViewController:self];

        NSLog(@"added new view controller");
    }

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectedCellIndexPath != nil && self.selectedCellIndexPath.row == indexPath.row) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected cell %ld", (long)indexPath.row);

    UIViewController * newVC = self.detailViewControllers[indexPath.row];
    [newVC.view addSubview:self.backButton];

    self.selectedCellIndexPath = indexPath;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.tableView.scrollEnabled = NO;
}

@end
