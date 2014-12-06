//
//  PASubscriptionsCollectionCell.h
//  Peck
//
//  Created by Aaron Taylor on 9/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subscription.h"

@interface PASubscriptionsCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *subscriptionTitle;
@property (strong, nonatomic) IBOutlet UISwitch *subscriptionSwitch;

- (void)switchSubscription:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) Subscription* subscription;

@property (strong, nonatomic) UIViewController* parentViewController;

@end
