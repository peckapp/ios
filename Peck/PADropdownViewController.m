//
//  PADropdownViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/11/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownViewController.h"



@interface PADropdownViewController () {
    
}

@property (nonatomic) NSString * primaryViewControllerIdentifier;
@property (nonatomic) NSArray * secondaryViewControllerIdentifiers;

// Designates the frame for child view controllers.
@property (nonatomic) CGRect frameForChildViewController;

@end

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
                                                PAFeedIdentifier,
                                                PAAddIdentifier,
                                                PACirclesIdentifier,
                                                PAProfileIdentifier];

    // Initialize dropdown bar
    dropdownBar = [[PADropdownBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)
                                             itemCount:[self.secondaryViewControllerIdentifiers count]
                                              delegate:self];

    // Create a frame for child view controllers
    self.frameForChildViewController = CGRectMake(0,
                                                  CGRectGetHeight(dropdownBar.frame),
                                                  CGRectGetWidth(self.view.frame),
                                                  CGRectGetHeight(self.view.frame) - CGRectGetHeight(dropdownBar.frame));

    // Instantiate primary view controller
    NSLog(@"Instantiating primary view contorller");
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Manage ViewControllers

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

#pragma mark - PADropdownBarDelegate

- (void) barDidSelectItemAtIndex:(NSInteger)index
{
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

                         [newVC didMoveToParentViewController:self];

                         [self displayChildViewController:newVC];
                         self.view.userInteractionEnabled = YES;
                     }];
}

- (void) barDidReselectItemAtIndex:(NSInteger)index
{
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

                         oldView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                         [newVC didMoveToParentViewController:self];

                         [self displayChildViewController:newVC];
                         self.view.userInteractionEnabled = YES;
                     }];
}

- (void) barDidSwitchSelectionToIndex:(NSInteger)index
{
    UIViewController * targetViewController = self.secondaryViewControllers[index];
    [self hideChildViewController:self.activeViewController];
    [self displayChildViewController:targetViewController];
}

@end

/*
UIViewController *src = (UIViewController *) self.sourceViewController;
UIViewController *dst = (UIViewController *) self.destinationViewController;

CGFloat distance = src.view.frame.size.height;
src.view.transform = CGAffineTransformMakeTranslation(0, 0);
dst.view.transform = CGAffineTransformMakeTranslation(0, 0);

[src.view.superview insertSubview:dst.view belowSubview:src.view];

[UIView animateWithDuration: 0.4
                      delay: 0.0
                    options: UIViewAnimationOptionCurveEaseOut
                 animations:^{
                     src.view.transform = CGAffineTransformMakeTranslation(0, distance);

                 }
                 completion:^(BOOL finished){
                     [dst.view removeFromSuperview];
                     [src presentViewController:dst animated:NO completion:NULL];
                 }
 ];
*/

/*
- (void) displayContentController: (UIViewController*) new;
{
    [self addChildViewController:new];
    new.view.frame = self.frameForContentController;
    [self.view addSubview: new.view];
    [new didMoveToParentViewController:self];
    self.activeViewController = new;
}

- (void) hideContentController: (UIViewController*) old
{
    [old willMoveToParentViewController:nil];
    [old.view removeFromSuperview];
    [old removeFromParentViewController];
}

- (void) transitionFromViewController: (UIViewController*) old
toViewController: (UIViewController*) new
{
    self.view.userInteractionEnabled = NO;
    [old willMoveToParentViewController:nil];
    [self addChildViewController:new];

    CGFloat distance = self.frameForContentController.size.height;
    new.view.frame = self.frameForContentController;
    new.view.transform = CGAffineTransformMakeTranslation(0, distance);

    [self transitionFromViewController: old toViewController: new
                              duration: 0.25 options:0
                            animations:^{
                                new.view.transform = CGAffineTransformMakeTranslation(0, 0);
                            }
                            completion:^(BOOL finished) {
                                [old removeFromParentViewController];
                                [new didMoveToParentViewController:self];
                                self.activeViewController = new;
                                self.view.userInteractionEnabled = YES;
                            }];
}
*/
