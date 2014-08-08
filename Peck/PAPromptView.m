//
//  PAPromptView.m
//  Peck
//
//  Created by John Karabinos on 8/8/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPromptView.h"
#import "PAInitialViewController.h"

@interface PAPromptView()

@property (strong, nonatomic) UIViewController* viewController;
@end


@implementation PAPromptView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)promptView:(UIViewController*)sender;
{
    PAPromptView *promptView = [[[NSBundle mainBundle] loadNibNamed:@"View" owner:nil options:nil] lastObject];
    
   promptView.viewController = sender;
    // make sure customView is not nil or the wrong class!
    if ([promptView isKindOfClass:[PAPromptView class]])
        return promptView;
    else
        return nil;
}

- (IBAction)registerButton:(id)sender {
    NSLog(@"register");
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *registerControllet = [loginStoryboard instantiateViewControllerWithIdentifier:@"register"];
    [self.viewController presentViewController:registerControllet animated:YES completion:nil];

}

- (IBAction)loginButton:(id)sender {
    NSLog(@"login");
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UINavigationController *loginRoot = [loginStoryboard instantiateInitialViewController];
    PAInitialViewController* root = loginRoot.viewControllers[0];
    root.justOpenedApp=NO;
    [self.viewController presentViewController:loginRoot animated:YES completion:nil];}
@end
