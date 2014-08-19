//
//  PANoContentView.h
//  Peck
//
//  Created by Aaron Taylor on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PANoContentView : UIView

//@property (nonatomic) UIColor * backgroundColor;
//@property (nonatomic) UIColor * textColor;

+ (PANoContentView *)noContentViewWithFrame:(CGRect)frame viewController:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *subscriptionsButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end
