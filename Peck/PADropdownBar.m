//
//  PADropdownBar.m
//  Peck
//
//  Created by Aaron Taylor on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownBar.h"

// Button dimensions. This should be calculated programatically from button image.
#define buttonWidth 50.0
#define buttonHeight 30.0
#define statusBarHeight 20.0

@interface PADropdownBar ()
@property (nonatomic, strong) NSObject <PADropdownBarDelegate> * delegate;
@property (nonatomic) NSInteger currentIndex;
@end

@implementation PADropdownBar

- (id) initWithFrame:(CGRect)frame itemCount:(NSUInteger)count delegate:(NSObject <PADropdownBarDelegate>*)dropdownDelegate;
{
    frame.size.height = statusBarHeight + buttonHeight;

    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];

        self.currentIndex = -1;

        // The spacing between each button
        CGFloat offset = CGRectGetWidth(frame) / count;

        // The x position of the first button
        CGFloat startX = (offset - buttonWidth) / 2;

        for (NSUInteger i = 0 ; i < count ; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
            //[button setImage:[UIImage imageNamed:@"graphics/button-selected.png"] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor grayColor];
            [button setTag:i];
            button.frame = CGRectMake(startX + i * offset, statusBarHeight, buttonWidth, buttonHeight);
            [self addSubview:button];
        }

        self.delegate = dropdownDelegate;
    }
    return self;
}

- (void) selectItem:(UIButton *)sender
{
    NSLog(@"Bar item selected.");
    int index = sender.tag;
    if (self.currentIndex == -1) {

        // Primary controller was selected, switch to secondary
        [self.delegate barDidSelectItemAtIndex:index];
        self.currentIndex = index;
    }
    else if (self.currentIndex == index) {

        // Secondary was already selected, switch to primary
        [self.delegate barDidDeselectItemAtIndex:index];
        self.currentIndex = -1;
    }
    else {

        // A different secondary was selected, switch to that one
        if (index < self.currentIndex) {
            [self.delegate barDidSlideLeftToIndex:index];
        }
        else {
            [self.delegate barDidSlideRightToIndex:index];
        }
        self.currentIndex = index;
    }
}

@end
