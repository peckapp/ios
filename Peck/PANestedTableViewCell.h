//
//  PANestedTableViewCell.h
//  Peck
//
//  Created by Jonas Luebbers on 8/8/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PANestedTableViewCellSubviewControllerProtocol

@required

- (void)setManagedObject:(NSManagedObject *)managedObject;

@end

@interface PANestedTableViewCell : UITableViewCell

@property (strong, nonatomic) UIViewController<PANestedTableViewCellSubviewControllerProtocol> * viewController;


@end
