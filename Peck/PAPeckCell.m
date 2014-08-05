//
//  PAPeckCell.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPeckCell.h"
#import "PAAssetManager.h"
#import "PASyncManager.h"

@implementation PAPeckCell

- (void)awakeFromNib
{
    PAAssetManager * assetManager = [PAAssetManager sharedManager];
    self.profileThumbnail = [assetManager createThumbnailWithFrame:self.profileTemplateView.frame imageView:[[UIImageView alloc] initWithImage:[assetManager profilePlaceholder]]];
    self.profileTemplateView.hidden = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)acceptInviteButton:(id)sender {
    if(!self.interactedWith){
        //if the cell has not been interacted with
        if([self.notification_type isEqualToString:@"circle_invite"]){
            [[PASyncManager globalSyncManager] acceptCircleInvite:self.invitation_id withPeckID:self.peckID];
        }else if([self.notification_type isEqualToString:@"event_invite"]){
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            
            NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [defaults objectForKey:@"user_id"],@"user_id",
                                      [defaults objectForKey:@"institution_id"],@"institution_id",
                                      [NSNumber numberWithLong:self.invitation_id] ,@"event_attended",
                                      @"simple", @"category",
                                      self.invited_by, @"added_by",
                                      nil];
            
            [[PASyncManager globalSyncManager] attendEvent:attendee forViewController:nil];
        }
    }
}

- (IBAction)declineInviteButton:(id)sender {
    if(!self.interactedWith){
        //if the cell has not been interacted with
        if([self.notification_type isEqualToString:@"circle_invite"]){
            [[PASyncManager globalSyncManager] deleteCircleMember:self.invitation_id withPeckID:self.peckID];
        }else if([self.notification_type isEqualToString:@"event_invite"]){
            
        }
    }
}
@end
