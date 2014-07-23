//
//  PASubscriptionCell.m
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASubscriptionCell.h"
#import "Subscription.h"
#import "PASyncManager.h"

@implementation PASubscriptionCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchSubscription:(id)sender {
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* institutionID = [defaults objectForKey:@"institution_id"];
    NSNumber* userID = [defaults objectForKey:@"user_id"];
    
    if(self.subscriptionSwitch.on){
        NSDictionary* subscriptionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                self.subscription.id, @"subscribed_to",
                                                institutionID, @"institution_id",
                                                userID, @"user_id",
                                                self.subscription.category, @"category",
                                                nil];

        [[PASyncManager globalSyncManager] postSubscription:subscriptionDictionary];
        
    }else{
        NSLog(@"remove subscription");
    }
    
}
@end
