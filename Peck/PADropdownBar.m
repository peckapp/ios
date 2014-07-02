//
//  PADropdownBar.m
//  Peck
//
//  Created by Aaron Taylor on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownBar.h"

// Button dimensions. This should be calculated programatically from button image.
#define barHeight 40.0
#define buffer 2.0
#define statusBarHeight 20.0

#define selected [UIColor blackColor]
#define deselected [UIColor grayColor]
#define background [UIColor whiteColor]

@interface PADropdownBar ()
@property (nonatomic) UIButton * currentButton;
@end

@implementation PADropdownBar

- (id) initWithFrame:(CGRect)frame itemCount:(NSUInteger)count
{
    frame.size.height = statusBarHeight + barHeight + buffer * 2;

    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];

        // The spacing between each button
        CGFloat buttonWidth = CGRectGetWidth(frame) / count;

        NSArray *icons = @[[UIImage imageNamed:@"dropdown_pecks.png"],
                           [UIImage imageNamed:@"dropdown_explore.png"],
                           [UIImage imageNamed:@"dropdown_post.png"],
                           [UIImage imageNamed:@"dropdown_circles.png"],
                           [UIImage imageNamed:@"dropdown_profile.png"]];

        for (NSUInteger i = 0 ; i < count ; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:icons[i] forState:UIControlStateNormal];
            [button setImage:icons[i] forState:UIControlStateSelected];
            [button setTag:i];
            button.backgroundColor = [UIColor clearColor];
            button.frame = CGRectMake(i * buttonWidth, statusBarHeight + buffer, buttonWidth, barHeight);
            [self addSubview:button];
        }

        self.currentButton = nil;
    }
    return self;
}

- (void) selectItem:(UIButton *)sender
{
    int index = (int)sender.tag;
    [self.currentButton setSelected:NO];

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
            [sender setSelected:YES];
        }
    }
    else {
        NSLog(@"Primary controller was selected, switch to secondary");
        [self.delegate barDidSelectItemAtIndex:index];
        self.currentButton = sender;
        [sender setSelected:YES];
    }
}

@end
