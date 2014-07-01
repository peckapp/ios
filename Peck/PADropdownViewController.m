//
//  PADropdownViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/11/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownViewController.h"
#import <Foundation/Foundation.h>

#pragma mark Private members

@interface PADropdownViewController () {}

@property (nonatomic) NSString * primaryViewControllerIdentifier;
@property (nonatomic) NSArray * secondaryViewControllerIdentifiers;

@property (nonatomic, retain) PAFilter * filter;
@property (nonatomic, retain) UIView * gradientView;

// Designates the frame for child view controllers.
@property (nonatomic) CGRect frameForChildViewController;

@end

#pragma mark - Implementation

@implementation PADropdownViewController

@synthesize dropdownBar;

// this method handles loading in the view
- (void)loadView
{
    // must not call [super loadView];
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize child view controllers
    self.primaryViewControllerIdentifier = PAPrimaryIdentifier;
    self.secondaryViewControllerIdentifiers = @[PAPecksIdentifier,
                                                PAExploreIdentifier,
                                                PAPostIdentifier,
                                                PACirclesIdentifier,
                                                PAProfileIdentifier];

    // Initialize dropdownBar
    dropdownBar = [[PADropdownBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)
                                             itemCount:[self.secondaryViewControllerIdentifiers count]
                                              delegate:self];

    // TODO: Frame is currently too big.
    // Create a frame for child view controllers
    self.frameForChildViewController = CGRectMake(0,
                                                  CGRectGetHeight(dropdownBar.frame),
                                                  CGRectGetWidth(self.view.frame),
                                                  CGRectGetHeight(self.view.frame) /*- CGRectGetHeight(dropdownBar.frame)*/);

    // Instantiate primary view controller
    NSLog(@"Instantiating primary view controller");
    self.primaryViewController = [self.storyboard instantiateViewControllerWithIdentifier:PAPrimaryIdentifier];
    self.primaryViewController.view.frame = self.frameForChildViewController;

    // Instantiate secondary view controllers
    NSLog(@"Instantiating secondary view controllers");
    NSMutableArray * svcCollector = [NSMutableArray arrayWithCapacity:self.secondaryViewControllerIdentifiers.count];
    [self.secondaryViewControllerIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop){
        NSString * identifier = (NSString*)obj;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        viewController.tabBarItem.tag = idx;
        viewController.restorationIdentifier = identifier;
        viewController.view.frame = self.frameForChildViewController;
        [svcCollector insertObject:viewController atIndex:idx];
    }];
    self.secondaryViewControllers = [svcCollector copy];

    // Add primary as child view controller
    [self addChildViewController:self.primaryViewController];
    [self.view addSubview: self.primaryViewController.view];
    [self.primaryViewController didMoveToParentViewController:self];
    self.activeViewController = self.primaryViewController;

    // gradient for filter
    self.gradientView = [[UIView alloc] initWithFrame:self.frameForChildViewController];
    self.gradientView.alpha = 0.0;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.gradientView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(0.0, 1.0);
    [self.gradientView.layer addSublayer:gradient];
    [self.view addSubview:self.gradientView];
    
    // filter item
    self.filter = [PAFilter filter];
    self.filter.delegate = self;
    [self.view addSubview:self.filter];
    [self.filter setFrameBasedOnSuperview];
    [self.filter presentUpwardForMode:PAFilterHomeMode];

    // Display dropdown bar
    [self.view addSubview:dropdownBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Manage ViewControllers

/*
- (void) displayChildViewController: (UIViewController*) newVC
{
    [self addChildViewController:newVC];
    [self.view addSubview: newVC.view];
    [newVC didMoveToParentViewController:self];
    self.activeViewController = newVC;
}

- (void) hideChildViewController: (UIViewController*) oldVC
{
    [oldVC willMoveToParentViewController:nil];
    [oldVC.view removeFromSuperview];
    [oldVC removeFromParentViewController];
}
 */

#pragma mark PADropdownBarDelegate

/*
- (void) barDidSelectItemAtIndex:(NSInteger)index;
{
    [self hideChildViewController:self.activeViewController];
    [self displayChildViewController:self.secondaryViewControllers[index]];

}

- (void) barDidDeselectItemAtIndex:(NSInteger)index;
{
    [self hideChildViewController:self.activeViewController];
    [self displayChildViewController:self.primaryViewController];
}

- (void) barDidSlideRightToIndex:(NSInteger)index;
{
    [self hideChildViewController:self.activeViewController];
    [self displayChildViewController:self.secondaryViewControllers[index]];
}

- (void) barDidSlideLeftToIndex:(NSInteger)index;
{
    [self hideChildViewController:self.activeViewController];
    [self displayChildViewController:self.secondaryViewControllers[index]];
}
*/

- (void) barDidSelectItemAtIndex:(NSInteger)index
{
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

    self.view.userInteractionEnabled = NO;

    // Hide child view controller
    [oldVC willMoveToParentViewController:nil];
    [oldVC removeFromParentViewController];

    [self.view insertSubview:newVC.view belowSubview:dropdownBar];

    CGFloat distance = self.frameForChildViewController.size.height;
    newVC.view.transform = CGAffineTransformMakeTranslation(0.0, -distance);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         newVC.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     }
                     completion:^(BOOL finished) {
                         [oldVC.view removeFromSuperview];

                         // Display child view controller
                         [self addChildViewController:newVC];
                         [newVC didMoveToParentViewController:self];
                         self.activeViewController = newVC;
                         self.view.userInteractionEnabled = YES;
                         
                     }];
    // dismisses filter as dropbown appears
    [self hideFilter];
    
}

- (void) barDidDeselectItemAtIndex:(NSInteger)index
{
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.primaryViewController;

    self.view.userInteractionEnabled = NO;

    // Hide child view controller
    [oldVC willMoveToParentViewController:nil];
    [oldVC removeFromParentViewController];

    [self.view insertSubview:newVC.view belowSubview:oldVC.view];

    CGFloat distance = self.frameForChildViewController.size.height;
    oldVC.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         oldVC.view.transform = CGAffineTransformMakeTranslation(0.0, -distance);
                     }
                     completion:^(BOOL finished) {
                         [oldVC.view removeFromSuperview];

                         // Display child view controller
                         [self addChildViewController:newVC];
                         [newVC didMoveToParentViewController:self];
                         self.activeViewController = newVC;
                         self.view.userInteractionEnabled = YES;
                         
                         // show the dropdown filter for the home mode
                         [self showFilterForMode:PAFilterHomeMode];
                     }];
}

- (void) barDidSlideLeftToIndex:(NSInteger)index
{
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

    self.view.userInteractionEnabled = NO;

    // Hide child view controller
    [oldVC willMoveToParentViewController:nil];
    [oldVC removeFromParentViewController];

    [self.view insertSubview:newVC.view belowSubview:dropdownBar];

    CGFloat distance = self.frameForChildViewController.size.width;
    oldVC.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    newVC.view.transform = CGAffineTransformMakeTranslation(-distance, 0.0);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         oldVC.view.transform = CGAffineTransformMakeTranslation(distance, 0.0);
                         newVC.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     }
                     completion:^(BOOL finished) {
                         [oldVC.view removeFromSuperview];

                         // Display child view controller
                         [self addChildViewController:newVC];
                         [newVC didMoveToParentViewController:self];
                         self.activeViewController = newVC;
                         self.view.userInteractionEnabled = YES;
                     }];
}

- (void) barDidSlideRightToIndex:(NSInteger)index
{
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

    self.view.userInteractionEnabled = NO;

    // Hide child view controller
    [oldVC willMoveToParentViewController:nil];
    [oldVC removeFromParentViewController];

    [self.view insertSubview:newVC.view belowSubview:dropdownBar];

    CGFloat distance = self.frameForChildViewController.size.width;
    oldVC.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    newVC.view.transform = CGAffineTransformMakeTranslation(distance, 0.0);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         oldVC.view.transform = CGAffineTransformMakeTranslation(-distance, 0.0);
                         newVC.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     }
                     completion:^(BOOL finished) {
                         [oldVC.view removeFromSuperview];
                         
                         // Display child view controller
                         [self addChildViewController:newVC];
                         [newVC didMoveToParentViewController:self];
                         self.activeViewController = newVC;
                         self.view.userInteractionEnabled = YES;
                     }];
}

# pragma mark Filter methods

- (void)hideFilter
{
    if (self.filter.presented) {
        [self.filter dismissDownward];
    }
}

- (void)showFilterForMode:(PAFilterType)mode
{
    if (!self.filter.presented) {
        [self.filter presentUpwardForMode:mode];
        [self.view bringSubviewToFront:self.filter];
    }
}

- (BOOL)requestFilterMode:(PAFilterMode)mode
{
    // preliminary options, not necessarily reflective of final filter choices
    if (mode == PAFilterStandardMode) {
        // show all events
        NSLog(@"Activate Filter for Standard Mode");
    } else if (mode == PAFilterSubscribedMode) {
        NSLog(@"Activate Filter for Subscribed Mode");
    } else if (mode == PAFilterInvitedMode) {
        NSLog(@"Activate Filter for Invited Mode");
    } else if (mode == PAFilterDiningMode) {
        NSLog(@"Activate Filter for Dining Mode");
    }
    return false;
}

- (void)shadeBackgroundViewOverDuration:(float)duration
{
    NSLog(@"Darken background for filter");
    [UIView animateWithDuration:duration animations:^{ self.gradientView.alpha = 0.8; }];
    //[self.view bringSubviewToFront:self.gradientView];
}

- (void)unshadeBackgroundViewOverDuration:(float)duration
{
    NSLog(@"Lighten background");
    [self.view bringSubviewToFront:self.gradientView];
    [UIView animateWithDuration:duration animations:^{ self.gradientView.alpha = 0.0; }];
}

@end