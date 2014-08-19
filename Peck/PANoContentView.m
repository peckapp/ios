//
//  PANoContentView.m
//  Peck
//
//  Created by Aaron Taylor on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PANoContentView.h"

@interface PANoContentView ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation PANoContentView

+ (PANoContentView *)noContentViewWithFrame:(CGRect)frame viewController:(id)sender;
{
    PANoContentView *noContentView = [[[NSBundle mainBundle] loadNibNamed:@"PANoContentView" owner:nil options:nil] lastObject];
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    noContentView.center = view.center;
    [view addSubview:noContentView];
    
    view.backgroundColor = [UIColor clearColor];
    
    return noContentView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.messageLabel.textColor = [UIColor whiteColor];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
