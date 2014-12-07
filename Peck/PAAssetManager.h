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
@property (strong, nonatomic) UIImage * subscriptionPlaceholder;
@property (strong, nonatomic) UIImage * imagePlaceholder;
@property (strong, nonatomic) UIImage * profilePlaceholder;
@property (strong, nonatomic) UIImage * greyBackground;
@property (strong, nonatomic) UIImage * cancelIcon;

@property (strong, nonatomic) UIColor *darkColor;
@property (strong, nonatomic) UIColor *lightColor;

+ (id)sharedManager;

- (UIView *)createShadowWithFrame:(CGRect)frame;
- (UIView *)createShadowWithFrame:(CGRect)frame top:(BOOL)top;
- (UIView *)createPanelWithFrame:(CGRect)frame rounded:(BOOL)rounded shadow:(BOOL)shadow;
- (UIImageView *)createThumbnailWithFrame:(CGRect)frame imageView:(UIImageView *)imageView;
- (UITextField *)createTextFieldWithFrame:(CGRect)frame;

@end
