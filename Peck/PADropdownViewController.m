//
//  PADropdownViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/11/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownViewController.h"
#import "PAFilter.h"

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

    // initializes and sets up the primary and secondary viewcontrollers
    [self initializeViewControllers];

    // Create tab bar items
    NSMutableArray * tempTabBarItems = [NSMutableArray arrayWithCapacity:self.secondaryViewControllers.count];
    [self.secondaryViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController * viewController = (UIViewController *)obj;
        [tempTabBarItems insertObject:viewController.tabBarItem atIndex:idx];
    }];

    dropdownBar = [[PADropdownBar alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), barHeight)];
    dropdownBar.items = [tempTabBarItems copy];
    dropdownBar.delegate = self;
    [self.view addSubview:dropdownBar];

    // Create a frame for child view controllers
    self.frameForContentController = CGRectMake(0, 20 + barHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - barHeight);

    // creates the filter object
    self.filter = [[PAFilter alloc] init];
    
    // Display primary view controller
    [self setupPrimaryController];
}

- (void) initializeViewControllers
{
    self.primaryViewControllerIdentifier = PAPrimaryIdentifier;
    self.secondaryViewControllerIdentifiers = @[PAPecksIdentifier,
                                                PAFeedIdentifier,
                                                PAAddIdentifier,
                                                PACirclesIdentifier,
                                                PAProfileIdentifier];
    
    // Instantiate primary view controller
    NSLog(@"Instantiating primary view contorller");
    self.primaryViewController = [self.storyboard instantiateViewControllerWithIdentifier:PAPrimaryIdentifier];
    
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

- (void) setupPrimaryController
{
    [self addChildViewController:self.primaryViewController];
    self.primaryViewController.view.frame = self.frameForContentController;
    [self.view addSubview: self.primaryViewController.view];
    [self.primaryViewController didMoveToParentViewController:self];
    self.activeViewController = self.primaryViewController;
    
    [self.view addSubview:self.filter];
    [self.filter presentUpwardForMode:PAFilterHomeMode];
}

// displays a secondary over the primary
- (void) displaySecondaryContentController: (UIViewController*) new;
{
    [new willMoveToParentViewController:self];
    [self addChildViewController:new];
    [self.view addSubview:new.view];
    
    new.view.frame = self.frameForContentController;
    
    self.activeViewController = new;
    [self.primaryViewController removeFromParentViewController];
    [self.primaryViewController.view removeFromSuperview];
    self.view.userInteractionEnabled = YES;
    [new didMoveToParentViewController:self];
    
    
    // presents filter in the proper mode
    [self.filter dismissDownward];
    [self.filter removeFromSuperview];
    if (new == self.secondaryViewControllers[1]) {
        [self.view addSubview:self.filter];
        [self.filter presentUpwardForMode:PAFilterExploreMode];
    }
}

// hides secondary to reveal and enable the primary
- (void) hideActiveSecondaryContentController
{
    [self.primaryViewController willMoveToParentViewController:self];
    [self addChildViewController:self.primaryViewController];
    [self.view addSubview:self.primaryViewController.view];
    
    // dismisses filter if it is active
    if (self.activeViewController == self.secondaryViewControllers[1]) {
        [self.filter removeFromSuperview];
        [self.filter dismissDownward];
    }
    [self.view addSubview:self.filter];
    [self.filter presentUpwardForMode:PAFilterHomeMode];
    
    self.primaryViewController.view.frame = self.frameForContentController;
    
    [self.activeViewController removeFromParentViewController];
    [self.activeViewController.view removeFromSuperview];
    [self.primaryViewController didMoveToParentViewController:self];
    self.activeViewController = self.primaryViewController;
    self.view.userInteractionEnabled = YES;
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
    
    // dismisses filter if it is active, presents it if moving to explore tab
    if (old == self.secondaryViewControllers[1]) {
        [self.filter removeFromSuperview];
        [self.filter dismissDownward];
    } else if (new == self.secondaryViewControllers[1]) {
        [self.view addSubview:self.filter];
        [self.filter presentUpwardForMode:PAFilterExploreMode];
    }
}

- (void) barDidSlideLeftToIndex:(NSInteger)index
{
    NSLog(@"%d", index);
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

    UIViewController * destinationViewController = self.secondaryViewControllers[item.tag];
    
    if (self.activeViewController == self.primaryViewController) {
        // primary is active, need to present a secondary on top of it
        [self displaySecondaryContentController:destinationViewController];
        
    } else if (self.activeViewController == destinationViewController) {
        
        // selected controller tapped again to dismiss it
        [self hideActiveSecondaryContentController]; //:self.activeViewController];
        //[self transitionFromViewController: self.activeViewController toViewController: self.primaryViewController];
        
    } else {
        
        [self transitionFromViewController: self.activeViewController toViewController: destinationViewController];
    }
}

- (void) barDidSlideRightToIndex:(NSInteger)index
{
    NSLog(@"%d", index);
    UIViewController * oldVC = self.activeViewController;
    UIViewController * newVC = self.secondaryViewControllers[index];

@end
