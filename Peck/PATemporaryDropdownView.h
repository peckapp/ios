//
//  PATemporaryDropdownView.h
//  Peck
//
//  Created by Jonas Luebbers on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PATemporaryDropdownView : UIView

@property (strong, nonatomic) UIView *hiddenView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton* todayButton;

- (void)temporarilyShowHiddenView;
- (void)showHiddenView;
- (void)hideHiddenView;
- (void)configureTodayButton:(NSInteger)selectedDay;
@end
