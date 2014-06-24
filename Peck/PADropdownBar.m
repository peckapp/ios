//
//  PADropdownBar.m
//  Peck
//
//  Created by Aaron Taylor on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownBar.h"

@interface PADropdownBar ()
@property (nonatomic, strong) NSObject <PADropdownBarDelegate> * delegate;
@end

@implementation PADropdownBar

- (id) initWithFrame:(CGRect)frame itemCount:(NSUInteger)count delegate:(NSObject <PADropdownBarDelegate>*)dropdownDelegate;
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];

        CGFloat offset = CGRectGetWidth(frame) / count;

        for (NSUInteger i = 0 ; i < count ; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self action:@selector(didSelectItem:) forControlEvents:UIControlEventTouchUpInside];
            //[button setImage:[UIImage imageNamed:@"graphics/button-selected.png"] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor grayColor];
            [button setTag:i];
            button.frame = CGRectMake(i * offset, 0.0, 50.0, 50.0);
            [self addSubview:button];
        }

        self.delegate = dropdownDelegate;
    }
    return self;
}

- (void) didSelectItem:(UIButton *)sender
{
    NSLog(@"PADropdownBar didSelectItem");
    int index = sender.tag;
    [self.delegate barDidSelectItemWithIndex:index];
}

- (void) selectItemAtIndex:(NSInteger)index;
{
    // Select buttons
}

@end
