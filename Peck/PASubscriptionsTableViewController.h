//
//  PASubscriptionsTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PASubscriptionsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray* departmentSubscriptions;
@property (strong, nonatomic) NSMutableArray* clubSubscriptions;
@property (strong, nonatomic) NSMutableArray* athleticSubscriptions;

@end
