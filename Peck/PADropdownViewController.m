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

// Designates the frame for child view controllers.
@property (nonatomic) CGRect frameForContentController;

@end

@implementation PADropdownViewController

@synthesize tabBar;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), barHeight)];

    self.frameForContentController = CGRectMake(0, 20 + barHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - barHeight);
    
    if (self.secondaryViewControllers == nil) {
        
        // no actual viewControllers were passed in, so if there is an array of identifers,
        // they are used to instantiate the classes from the storyboard
        
        if (self.secondaryViewControllerIdentifiers != nil) {
            NSLog(@"Instantiating secondaryViewControllers from the storyboard based on their identifiers");

            NSMutableArray * svcCollector = [NSMutableArray arrayWithCapacity:self.secondaryViewControllerIdentifiers.count];
            
            [self.secondaryViewControllerIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop){
                NSString * identifier = (NSString*)obj;
                UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
                viewController.tabBarItem.tag = idx;
                viewController.restorationIdentifier = identifier;
                [svcCollector insertObject:viewController atIndex:idx];
            }];
            
            // assigns the viewControllers to the dropdownViewController class
            self.secondaryViewControllers = [svcCollector copy];
            
        } else {
            [NSException raise:@"nil values for both secondaryViewControllers and secondaryViewControllerIdentifiers"
                        format:@"must instantiate one of these"];
        }
        
    } else {
        NSLog(@"attempting to use pre-specified secondaryViewControllers in PADropdownViewController (functionality un-implemented)");
    
    }
    
    // does the necessary general setup for each viewcontroller, retreiving tabBarItems and passing it the managedObject Context
    
    NSMutableArray * tempTabBarItems = [NSMutableArray arrayWithCapacity:self.secondaryViewControllers.count];
    
    [self.secondaryViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController * viewController = (UIViewController *)obj;
        [tempTabBarItems insertObject:viewController.tabBarItem atIndex:idx];
    }];
    tabBar.items = [tempTabBarItems copy];
    
    tabBar.delegate = self;
    
    [self.view addSubview:tabBar];
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

#pragma mark Storyboard Support

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[PADropdownViewControllerSegue class]]) {
        [self displayContentController: segue.destinationViewController];
    }
}

-(void) presentViewControllerAtIndex:(NSInteger)index animated:(BOOL)flag completion:(void (^)(void))completion
{
    UIViewController * destController =[self.secondaryViewControllers objectAtIndex:index];
    [super presentViewController:destController animated:flag completion:completion];
}

# pragma mark - UITabBarDelegate methods

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    NSString * identifier = self.secondaryViewControllerIdentifiers[item.tag];
    [self performSegueWithIdentifier:identifier sender:self];

//    } else { // presents the view controller programatically if storyboards are unused
//        UIViewController *selectedViewController = self.secondaryViewControllers[item.tag];
//        
//        // this is just a simple modal presentation. custom behavior must be done through the segue
//        [self presentViewController:selectedViewController animated:YES completion:nil];
//    }

}


@end


# pragma mark - Segues

@implementation PADropdownViewControllerSegue

-(void) perform
{
    // handles passing core data managed object context to the destinationViewControllers
    UIViewController <PACoreDataProtocol> * srcViewController = (UIViewController <PACoreDataProtocol> *)self.sourceViewController;
    if ([self.destinationViewController conformsToProtocol:@protocol(PACoreDataProtocol)]) { // passes managedObjectContext if viewController conforms to protocol
        
        UIViewController <PACoreDataProtocol> * cdDestViewController = (UIViewController <PACoreDataProtocol> *)self.destinationViewController;
        cdDestViewController.managedObjectContext = srcViewController.managedObjectContext;
        
    } else if ([self.destinationViewController isMemberOfClass:[UINavigationController class]]) { // passes mOC to topViewController of NavController if possible
        
        UIViewController * topViewController = ((UINavigationController*)self.destinationViewController).topViewController;
        
        if ([topViewController conformsToProtocol:@protocol(PACoreDataProtocol)]) {
            UIViewController <PACoreDataProtocol> * cdViewController = (UIViewController <PACoreDataProtocol> *)topViewController;
            cdViewController.managedObjectContext = srcViewController.managedObjectContext;
        }
    }

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