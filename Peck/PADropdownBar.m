//
//  PADropdownBar.m
//  Peck
//
//  Created by Aaron Taylor on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownBar.h"

// Button dimensions. This should be calculated programatically from button image.
#define buttonWidth 40.0
#define buttonHeight 40.0
#define statusBarHeight 20.0

#define selected [UIColor blackColor]
#define deselected [UIColor grayColor]
#define background [UIColor whiteColor]

@interface PADropdownBar ()
@property (nonatomic, strong) NSObject <PADropdownBarDelegate> * delegate;
@property (nonatomic) UIButton * currentButton;
@end

@implementation PADropdownBar

- (id) initWithFrame:(CGRect)frame itemCount:(NSUInteger)count delegate:(NSObject <PADropdownBarDelegate>*)dropdownDelegate;
{
    frame.size.height = statusBarHeight + buttonHeight;

    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = background;

        // The spacing between each button
        CGFloat offset = CGRectGetWidth(frame) / count;

        // The x position of the first button
        CGFloat startX = (offset - buttonWidth) / 2;

        for (NSUInteger i = 0 ; i < count ; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
            //[button setImage:[UIImage imageNamed:@"graphics/button-selected.png"] forState:UIControlStateNormal];
            [button setTag:i];
            button.backgroundColor = deselected;
            button.frame = CGRectMake(startX + i * offset, statusBarHeight, buttonWidth, buttonHeight);
            [self addSubview:button];
        }

        self.delegate = dropdownDelegate;
        self.currentButton = nil;
    }
    return self;
}

- (void) selectItem:(UIButton *)sender
{
    int index = (int)sender.tag;
    self.currentButton.backgroundColor = deselected;

    if (self.currentButton) {
        int currentIndex = (int)self.currentButton.tag;

        if (currentIndex == index) {
            NSLog(@"Secondary was already selected, switch to primary");
            [self.delegate barDidDeselectItemAtIndex:index];
            self.currentButton = nil;
        }
        else {
            NSLog(@"A different secondary was selected, switch to that one");
            if (index < currentIndex) {
                [self.delegate barDidSlideLeftToIndex:index];
            }
            else {
                [self.delegate barDidSlideRightToIndex:index];
            }
            self.currentButton = sender;
            sender.backgroundColor = selected;
        }
    }
    else {
        NSLog(@"Primary controller was selected, switch to secondary");
        [self.delegate barDidSelectItemAtIndex:index];
        self.currentButton = sender;
        sender.backgroundColor = selected;
    }
}

@end
