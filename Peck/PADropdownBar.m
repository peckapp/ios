//
//  PADropdownBar.m
//  Peck
//
//  Created by Aaron Taylor on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownBar.h"
#import "PAAppDelegate.h"

// Button dimensions. This should be calculated programatically from button image.
#define barHeight 40.0
#define buffer 2.0
#define statusBarHeight 20.0

#define selected [UIColor blackColor]
#define deselected [UIColor grayColor]
#define background [UIColor whiteColor]

@interface PADropdownBar ()

@property (nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSArray * buttons;

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

        NSArray *icons = @[[UIImage imageNamed:@"feather"],
                           [UIImage imageNamed:@"explore"],
                           [UIImage imageNamed:@"post"],
                           [UIImage imageNamed:@"circles"],
                           [UIImage imageNamed:@"profile"]];

        NSMutableArray * collector = [[NSMutableArray alloc] init];
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
            [collector addObject:button];
        }

        self.buttons = [collector copy];
        self.currentIndex = -1;
        
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        appdelegate.dropDownBar = self;
        
    }
    return self;
}

- (void) selectItem:(UIButton *)sender
{
    NSInteger index = sender.tag;
    if (index == self.currentIndex) {
        [self deselectAllItems];
    }
    else {
        [self selectItemAtIndex:index];
    }
}

- (void)selectItemAtIndex:(NSInteger)index
{
    if (self.currentIndex == -1) {
        [self.delegate barDidSelectItemAtIndex:index];
    }
    else {
        if (index < self.currentIndex) {
            [self.delegate barDidSlideLeftToIndex:index];
        }
        else {
            [self.delegate barDidSlideRightToIndex:index];
        }

        [self.buttons[self.currentIndex] setSelected:NO];
    }

    self.currentIndex = index;
    [self.buttons[index] setSelected:YES];
}

- (void)deselectAllItems
{
    if (self.currentIndex != -1) {
        [self.delegate barDidDeselectItemAtIndex:self.currentIndex];
        [self.buttons[self.currentIndex] setSelected:NO];
        self.currentIndex = -1;
    }
}

@end
