//
//  PASubscriptionCell.h
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subscription.h"

@interface PASubscriptionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *subscriptionTitle;
- (IBAction)switchSubscription:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *subscriptionSwitch;
@property (weak, nonatomic) Subscription* subscription;
@end
