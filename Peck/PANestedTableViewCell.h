//
//  PANestedTableViewCell.h
//  Peck
//
//  Created by Jonas Luebbers on 8/8/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PANestedInfoViewController.h"
#import "PANestedCellControllerProtocol.h"

@class PANestedInfoViewController;

@interface PANestedTableViewCell : UITableViewCell

@property (strong, nonatomic) UIViewController<PANestedCellControllerProtocol>* viewController;

@end
