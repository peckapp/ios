//
//  PADropdownViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/11/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownViewController.h"
#import "PAFilter.h"

#pragma mark Private members

@interface PADropdownViewController () {}

@property (nonatomic) NSString * primaryViewControllerIdentifier;
@property (nonatomic) NSArray * secondaryViewControllerIdentifiers;

@property (nonatomic, retain) PAFilter * filter;

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

    // Create a frame for child view controllers
    self.frameForChildViewController = CGRectMake(0,
                                                  CGRectGetHeight(dropdownBar.frame),
                                                  CGRectGetWidth(self.view.frame),
                                                  CGRectGetHeight(self.view.frame) - CGRectGetHeight(dropdownBar.frame));

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

    // Display views
    [self.view addSubview:dropdownBar];
    [self displayChildViewController:self.primaryViewController];
    
    self.filter = [PAFilter filter];
    [self.view addSubview:self.filter];
    [self.filter presentUpwardForMode:PAFilterHomeMode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Manage ViewControllers

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

#pragma mark PADropdownBarDelegate

- (void) barDidSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"%ld", (long)index);
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

    self.view.userInteractionEnabled = NO;
    [oldVC willMoveToParentViewController:nil];
    [newVC willMoveToParentViewController:self];
    [self hideChildViewController:oldVC];

    UIView * oldView = oldVC.view;
    UIView * newView = newVC.view;

    [self.view insertSubview:oldView belowSubview:dropdownBar];
    [self.view insertSubview:newView belowSubview:dropdownBar];

    CGFloat distance = self.frameForChildViewController.size.height;
    newView.transform = CGAffineTransformMakeTranslation(0.0, -distance);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         newView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     }
                     completion:^(BOOL finished) {
                         [oldVC removeFromParentViewController];
                         [newVC removeFromParentViewController];

                         [oldVC didMoveToParentViewController:nil];
                         [newVC didMoveToParentViewController:self];

                         [self displayChildViewController:newVC];
                         self.view.userInteractionEnabled = YES;
                         
                     }];
    // dismisses filter as dropbown appears
    [self hideFilter];
    
}

- (void) barDidDeselectItemAtIndex:(NSInteger)index
{
    NSLog(@"%ld", (long)index);
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.primaryViewController;

    self.view.userInteractionEnabled = NO;
    [oldVC willMoveToParentViewController:nil];
    [newVC willMoveToParentViewController:self];
    [self hideChildViewController:oldVC];

    UIView * oldView = oldVC.view;
    UIView * newView = newVC.view;

    [self.view insertSubview:newView belowSubview:dropdownBar];
    [self.view insertSubview:oldView belowSubview:dropdownBar];

    CGFloat distance = self.frameForChildViewController.size.height;
    oldView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         oldView.transform = CGAffineTransformMakeTranslation(0.0, -distance);
                     }
                     completion:^(BOOL finished) {
                         [oldVC removeFromParentViewController];
                         [newVC removeFromParentViewController];

                         [oldVC didMoveToParentViewController:nil];
                         [newVC didMoveToParentViewController:self];

                         [self displayChildViewController:newVC];
                         self.view.userInteractionEnabled = YES;
                         
                         // show the dropdown filter for the home mode
                         [self showFilterForMode:PAFilterHomeMode];
                     }];
}

- (void) barDidSlideLeftToIndex:(NSInteger)index
{
    NSLog(@"%ld", (long)index);
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

    self.view.userInteractionEnabled = NO;
    [oldVC willMoveToParentViewController:nil];
    [newVC willMoveToParentViewController:self];
    [self hideChildViewController:oldVC];

    UIView * oldView = oldVC.view;
    UIView * newView = newVC.view;

    [self.view insertSubview:newView belowSubview:dropdownBar];
    [self.view insertSubview:oldView belowSubview:dropdownBar];

    CGFloat distance = self.frameForChildViewController.size.width;
    oldView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    newView.transform = CGAffineTransformMakeTranslation(-distance, 0.0);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         oldView.transform = CGAffineTransformMakeTranslation(distance, 0.0);
                         newView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     }
                     completion:^(BOOL finished) {
                         [oldVC removeFromParentViewController];
                         [newVC removeFromParentViewController];

                         [oldVC didMoveToParentViewController:nil];
                         [newVC didMoveToParentViewController:self];

                         [self displayChildViewController:newVC];
                         self.view.userInteractionEnabled = YES;
                     }];
}

- (void) barDidSlideRightToIndex:(NSInteger)index
{
    NSLog(@"%ld", (long)index);
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

    self.view.userInteractionEnabled = NO;
    [oldVC willMoveToParentViewController:nil];
    [newVC willMoveToParentViewController:self];
    [self hideChildViewController:oldVC];

    UIView * oldView = oldVC.view;
    UIView * newView = newVC.view;

    [self.view insertSubview:newView belowSubview:dropdownBar];
    [self.view insertSubview:oldView belowSubview:dropdownBar];

    CGFloat distance = self.frameForChildViewController.size.width;
    oldView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    newView.transform = CGAffineTransformMakeTranslation(distance, 0.0);

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:0
                     animations:^{
                         oldView.transform = CGAffineTransformMakeTranslation(-distance, 0.0);
                         newView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     }
                     completion:^(BOOL finished) {
                         [oldVC removeFromParentViewController];
                         [newVC removeFromParentViewController];

                         [oldVC didMoveToParentViewController:nil];
                         [newVC didMoveToParentViewController:self];

                         [self displayChildViewController:newVC];
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

- (void)showFilterForMode:(PAFilterMode)mode
{
    if (!self.filter.presented) {
        [self.filter presentUpwardForMode:mode];
        [self.view bringSubviewToFront:self.filter];
    }
}

@end