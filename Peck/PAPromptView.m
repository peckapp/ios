//
//  PAPromptView.m
//  Peck
//
//  Created by John Karabinos on 8/8/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPromptView.h"
#import "PAInitialViewController.h"
#import "PAAssetManager.h"

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

+ (UIView *)promptViewWithFrame:(CGRect)frame viewController:(id)sender;
{
    PAPromptView *prompt = [[[NSBundle mainBundle] loadNibNamed:@"PAPromptView" owner:nil options:nil] lastObject];
    UIView *view = [[UIView alloc] initWithFrame:frame];
    prompt.center = view.center;
    [view addSubview:prompt];
    
    prompt.viewController = sender;
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    return view;
}

- (IBAction)registerButton:(id)sender {
    NSLog(@"register");
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *registerController = [loginStoryboard instantiateViewControllerWithIdentifier:@"register"];
    [self.viewController presentViewController:registerController animated:YES completion:nil];

}

- (IBAction)loginButton:(id)sender {
    NSLog(@"login");
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UINavigationController *loginRoot = [loginStoryboard instantiateInitialViewController];
    PAInitialViewController* root = loginRoot.viewControllers[0];
    root.direction=@"none";
    [self.viewController presentViewController:loginRoot animated:YES completion:nil];}
@end
