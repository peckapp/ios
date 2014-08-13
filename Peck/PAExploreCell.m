//
//  PAFeedCell.m
//  Peck
//
//  Created by Jonas Luebbers on 6/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAExploreCell.h"
#import "PASyncManager.h"
#import "PAMethodManager.h"
#import "PAFetchManager.h"

@implementation PAExploreCell

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)attendEvent:(id)sender {
    if([self.category isEqualToString:@"event"]){
        NSLog(@"attend the event");
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"authentication_token"]){
            NSLog(@"attend the event");
            NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [defaults objectForKey:@"user_id"],@"user_id",
                                      [defaults objectForKey:@"institution_id"],@"institution_id",
                                      self.exploreID,@"event_attended",
                                      @"simple", @"category",
                                      [defaults objectForKey:@"user_id"], @"added_by",
                                      nil];
            
            [[PASyncManager globalSyncManager] attendEvent:attendee forViewController:nil];
            [[PAFetchManager sharedFetchManager] deleteObject:self.exploreID withEntityType:@"Explore" andCategory:@"event"];
           
            
        }else{
            [[PAMethodManager sharedMethodManager] showRegisterAlert:@"attend an event" forViewController:nil];
        }

    }
}
@end
