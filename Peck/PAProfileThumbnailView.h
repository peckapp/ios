//
//  PAProfileThumbnailView.h
//  Peck
//
//  Created by Jonas Luebbers on 7/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAProfileThumbnailView : UIView

@property (nonatomic) UIImage * profileImage;

- (id)initWithFrame:(CGRect)frame subFrame:(CGRect)subFrame image:(UIImage *)image;

@end
