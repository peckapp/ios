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
        [[PASyncManager globalSyncManager] acceptCircleInvite:self.invitation_id withPeckID:self.peckID];
    }
}

- (IBAction)declineInviteButton:(id)sender {
    if(!self.interactedWith){
        //if the cell has not been interacted with
        [[PASyncManager globalSyncManager] deleteCircleMember:self.invitation_id withPeckID:self.peckID];
    }
}
@end
