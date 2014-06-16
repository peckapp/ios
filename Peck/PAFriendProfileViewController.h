//
//  PAFriendProfileViewController.h
//  Peck
//
//  Created by John Karabinos on 6/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAFriendProfileViewController : UIViewController
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextView *blurbTextView;

@end
