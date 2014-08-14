//
//  PAPromptView.h
//  Peck
//
//  Created by John Karabinos on 8/8/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAPromptView : UIView
- (IBAction)registerButton:(id)sender;
- (IBAction)loginButton:(id)sender;
+ (UIView *)promptViewWithFrame:(CGRect)frame viewController:(id)sender;

@end
