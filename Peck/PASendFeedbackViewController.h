//
//  PASendFeedbackViewController.h
//  Peck
//
//  Created by John Karabinos on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PASendFeedbackViewController : UIViewController
- (IBAction)cancelButton:(id)sender;
- (IBAction)sendButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categoryControl;

@end
