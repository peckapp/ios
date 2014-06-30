//
//  PACircleCellTableViewCell.h
//  Peck
//
//  Created by John Karabinos on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACirclesTableViewController.h"

@interface PACircleCell : UITableViewCell <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *circleTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic, assign) id <PACirclesControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger members;
@property BOOL loadedImages;

-(void)addImages:(NSArray*)members;
@end
