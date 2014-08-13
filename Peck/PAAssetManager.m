//
//  PAAssetManager.m
//  Peck
//
//  Created by Jonas Luebbers on 7/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAAssetManager.h"

@implementation PAAssetManager

+ (id)sharedManager {
    static PAAssetManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init {
    if (self = [super init]) {

        self.eventPlaceholder = [UIImage imageNamed:@"event-placeholder"];
        self.imagePlaceholder = [UIImage imageNamed:@"image-placeholder"];
        self.profilePlaceholder = [UIImage imageNamed:@"profile-placeholder"];
        self.unavailableColor = [UIColor colorWithHue:1 saturation:0 brightness:0.9 alpha:1];
        self.darkColor = [UIColor colorWithRed:29/255.0 green:28/255.0 blue:36/255.0 alpha:1];
        self.lightColor = [UIColor colorWithRed:59/255.0 green:56/255.0 blue:71/255.0 alpha:1];
        
        
        CGSize size = CGSizeMake(200, 200);
        self.greyBackground = [self imageWithColor:[UIColor whiteColor] andSize:size];

    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIView *)createShadowWithFrame:(CGRect)frame
{
    UIImageView *shadow = [[UIImageView alloc] initWithFrame:frame];
    shadow.image = [[UIImage imageNamed:@"drop-shadow"]stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    return shadow;
}

- (UIView *)createShadowWithFrame:(CGRect)frame top:(BOOL)top
{
    UIImageView *dropShadow = [[UIImageView alloc] initWithFrame:frame];
    dropShadow.image = [[UIImage imageNamed:@"drop-shadow-horizontal"]stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    if (top) {
        dropShadow.transform = CGAffineTransformMakeRotation(M_PI);
    }
    return dropShadow;
}

- (UIImageView *)createThumbnailWithFrame:(CGRect)frame imageView:(UIImageView *)imageView
{
    CGFloat size = 40;

    //UIButton * button = [[UIButton alloc]initWithFrame:frame];

    imageView.frame = CGRectMake(frame.size.width / 2 - size / 2, frame.size.height / 2 - size / 2, size, size);
    imageView.layer.cornerRadius = size / 2;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    //[button addSubview:imageView];

    return imageView;
}

- (UITextField *)createTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:17.0];
    textField.backgroundColor = [UIColor clearColor];
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textField;
}
@end
