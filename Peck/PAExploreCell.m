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
#import "PAUtils.h"

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
    if([self.category isEqualToString:@"event"] || [self.category isEqualToString:@"athletic"]){
        NSLog(@"attempt to attend the event");
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"authentication_token"]){
            
            if([[defaults objectForKey:@"home_institution"] integerValue]==[[defaults objectForKey:@"institution_id"] integerValue]){
                [self continueAttending];
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Foreign Institution" message:@"Please switch to your home institution to attend events" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }else{
            [[PAMethodManager sharedMethodManager] showRegisterAlert:@"attend an event" forViewController:nil];
        }

    }
}

-(void)continueAttending{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"attend the event");
    
    if (SHOW_ATTEND_TUTORIAL) {
        [[PAMethodManager sharedMethodManager] showTutorialAlertWithTitle:@"Attending an Event"
                                                               andMessage:@"Events that you choose to attend are removed from the explore feed and displayed in the homepage"];
        DID_SHOW_ATTEND_TUTORIAL;
    }
    
    
    NSString*category = @"simple";
    if([self.category isEqualToString:@"athletic"]){
        category = @"athletic";
    }
    NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:@"user_id"],@"user_id",
                              [defaults objectForKey:@"institution_id"],@"institution_id",
                              [NSNumber numberWithLong:self.exploreID],@"event_attended",
                              category, @"category",
                              [defaults objectForKey:@"user_id"], @"added_by",
                              nil];
    
    [[PASyncManager globalSyncManager] attendEvent:attendee forViewController:nil];
    [[PAFetchManager sharedFetchManager] deleteObject:[NSNumber numberWithLong: self.exploreID] withEntityType:@"Explore" andCategory:self.category];
}
@end
