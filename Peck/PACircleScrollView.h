//
//  PACircleScrollView.h
//  Peck
//
//  Created by John Karabinos on 6/25/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACreateCircleViewController.h"

@protocol PACirclePeersControllerDelegate;

@interface PACircleScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property NSInteger numberOfMembers;
@property (nonatomic, assign) id<PACirclePeersControllerDelegate,UIScrollViewDelegate> delegate;

@property (strong, nonatomic) NSMutableArray * nameLabels;
@property (strong, nonatomic) NSMutableArray * memberPhotos;

-(void)addPeer:(UIImage*)image WithName:(NSString *)name;
-(void)removePeer:(int)peer;


@end

