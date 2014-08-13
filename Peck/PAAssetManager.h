//
//  PAAssetManager.h
//  Peck
//
//  Created by Jonas Luebbers on 7/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAAssetManager : NSObject

@property (strong, nonatomic) UIImage * eventPlaceholder;
@property (strong, nonatomic) UIImage * imagePlaceholder;
@property (strong, nonatomic) UIImage * profilePlaceholder;
@property (strong, nonatomic) UIImage * horizontalShadow;
@property (strong, nonatomic) UIImage * greyBackground;

@property (strong, nonatomic) UIColor* unavailableColor;
+ (id)sharedManager;

- (UIImageView *)createThumbnailWithFrame:(CGRect)frame imageView:(UIImageView *)imageView;

@end
