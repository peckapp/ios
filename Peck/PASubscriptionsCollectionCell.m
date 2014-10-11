//
//  PASubscriptionsCollectionCell.m
//  Peck
//
//  Created by Aaron Taylor on 9/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASubscriptionsCollectionCell.h"
#import "PASubscriptionsCollectionViewController.h"

@implementation PASubscriptionsCollectionCell


- (IBAction)switchSubscription:(id)sender {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* institutionID = [defaults objectForKey:@"institution_id"];
    NSNumber* userID = [defaults objectForKey:@"user_id"];
    PASubscriptionsCollectionViewController *parent = (PASubscriptionsCollectionViewController*)self.parentViewController;
    NSString* subKey = [self.subscription.category stringByAppendingString:[self.subscription.id stringValue]];
    
    if(self.subscriptionSwitch.on){
        self.subscription.subscribed = [NSNumber numberWithBool:YES];
        
        if(![parent.deletedSubscriptions objectForKey:subKey]){
            //if the subscription is not on the list to be deleted
            NSDictionary* subscriptionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    self.subscription.id, @"subscribed_to",
                                                    institutionID, @"institution_id",
                                                    userID, @"user_id",
                                                    self.subscription.category, @"category",
                                                    nil];
            
            [parent.addedSubscriptions setObject:subscriptionDictionary forKey:subKey];
        }else{
            [parent.deletedSubscriptions removeObjectForKey:subKey];
        }
        
    }else{
        NSLog(@"remove subscription");
        self.subscription.subscribed = [NSNumber numberWithBool:NO];
        if(![parent.addedSubscriptions objectForKey:subKey]){
            //if the subscription is not on the list to be added
            [parent.deletedSubscriptions setObject:self.subscription.subscription_id forKey:subKey];
        }else{
            [parent.addedSubscriptions removeObjectForKey:subKey];
        }
        
    }
    
}

@end
