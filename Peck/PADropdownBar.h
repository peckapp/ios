//
//  PADropdownBar.h
//  Peck
//
//  Created by Aaron Taylor on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PADropdownBar;
@protocol PADropdownBarDelegate
- (void)barDidSelectItemAtIndex:(NSInteger)index;
- (void)barDidDeselectItemAtIndex:(NSInteger)index;
- (void)barDidSlideRightToIndex:(NSInteger)index;
- (void)barDidSlideLeftToIndex:(NSInteger)index;
@end

@interface PADropdownBar : UIView

@property (nonatomic, strong) NSObject <PADropdownBarDelegate> * delegate;

- (id)initWithFrame:(CGRect)frame itemCount:(NSUInteger)count;
- (void)selectItemAtIndex:(NSInteger)index;
- (void)deselectAllItems;

@end
