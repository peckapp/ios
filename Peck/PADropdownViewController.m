//
//  PADropdownViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/11/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownViewController.h"

#define barHeight 50

@interface PADropdownViewController () {
    
}

@property (nonatomic) NSString * primaryViewControllerIdentifier;
@property (nonatomic) NSArray * secondaryViewControllerIdentifiers;

// Designates the frame for child view controllers.
@property (nonatomic) CGRect frameForContentController;

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
    NSLog(@"Instantiating secondary view controller");
    NSMutableArray * svcCollector = [NSMutableArray arrayWithCapacity:self.secondaryViewControllerIdentifiers.count];
    [self.secondaryViewControllerIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop){
        NSString * identifier = (NSString*)obj;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
        viewController.tabBarItem.tag = idx;
        viewController.restorationIdentifier = identifier;
        [svcCollector insertObject:viewController atIndex:idx];
    }];
    self.secondaryViewControllers = [svcCollector copy];

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

    // Display primary view controller
    [self displayContentController: self.primaryViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Manage ViewControllers

- (void) displayContentController: (UIViewController*) content;
{
    [self addChildViewController:content];
    content.view.frame = self.frameForContentController;
    [self.view addSubview: content.view];
    [content didMoveToParentViewController:self];
}

- (void) hideContentController: (UIViewController*) content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void) cycleFromViewController: (UIViewController*) old
                toViewController: (UIViewController*) new
{
    [self addChildViewController:new];
    [old willMoveToParentViewController:nil];

    [self transitionFromViewController:old
                      toViewController:new
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{}
                            completion:^(BOOL finished) {
                                [old removeFromParentViewController];
                                [new didMoveToParentViewController:self];
                            }];
}

# pragma mark - UITabBarDelegate methods

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    UIViewController * destinationViewController = self.secondaryViewControllers[item.tag];
    // [self cycleFromViewController: self.activeViewController toViewController: destinationViewController];
    
    [self hideContentController:self.activeViewController];
    [self displayContentController:destinationViewController];

    self.activeViewController = destinationViewController;

    /*
    // TODO: this passing may be unnecessary because child view controllers can access the managed object context from DropdownViewController

    // handles passing core data managed object context to the destinationViewControllers
    UIViewController <PACoreDataProtocol> * srcViewController = (UIViewController <PACoreDataProtocol> *)self.activeViewController;
    if ([destinationViewController isMemberOfClass:[UINavigationController class]]) { // passes mOC to topViewController of NavController if possible

        UIViewController * topViewController = ((UINavigationController*)destinationViewController).topViewController;

        self.activeViewController = topViewController;
        if ([topViewController conformsToProtocol:@protocol(PACoreDataProtocol)]) {
            UIViewController <PACoreDataProtocol> * cdViewController = (UIViewController <PACoreDataProtocol> *)topViewController;
            cdViewController.managedObjectContext = srcViewController.managedObjectContext;
        }
    } else if ([destinationViewController conformsToProtocol:@protocol(PACoreDataProtocol)]) { // passes managedObjectContext if viewController conforms to protocol

        self.activeViewController = destinationViewController;

        UIViewController <PACoreDataProtocol> * cdDestViewController = (UIViewController <PACoreDataProtocol> *)destinationViewController;
        cdDestViewController.managedObjectContext = srcViewController.managedObjectContext;
        
    } else {
        NSLog(@"Managed Object context not passed");
    }
     */
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
