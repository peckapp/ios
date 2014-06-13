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

@property (nonatomic) BOOL animated;

// marks whether or not this class is using classes and segues from the storyboard, or programatically handling them
@property (nonatomic) BOOL usingStoryboard;

// number of secondary view controllers
@property (nonatomic) NSInteger numberOfSecondaries;

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
    
    tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 49)];    
    
    if (self.secondaryViewControllers == nil) {
        
        // no actual viewControllers were passed in, so if there is an array of identifers,
        // they are used to instantiate the classes from the storyboard
        
        if (self.secondaryViewControllerIdentifiers != nil) {
            NSLog(@"Instantiating secondaryViewControllers from the storyboard based on their identifiers");
            
            self.usingStoryboard = YES;
            
            self.numberOfSecondaries = self.secondaryViewControllerIdentifiers.count;
            NSMutableArray * svcCollector = [NSMutableArray arrayWithCapacity:self.numberOfSecondaries];
            
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

#pragma mark Assigning ViewControllers

-(void) setSecondaryViewControllers:(NSArray *)secondaryViewControllers animated:(BOOL)animated
{
    self.animated = animated;
    self.secondaryViewControllers = secondaryViewControllers;
}

#pragma mark Storyboard Support

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    if ([segue isKindOfClass:[PADropdownViewControllerSegue class]]) {
        if ([identifier isEqualToString:PAPecksIdentifier]) {
            
        } else if ([identifier isEqualToString:PAFeedIdentifier]) {
            
        } else if ([identifier isEqualToString:PAAddIdentifier]) {
            
        } else if ([identifier isEqualToString:PACirclesIdentifier]) {
            
        } else if ([identifier isEqualToString:PAProfileIdentifier]) {
            
        } else if ([identifier isEqualToString:PAPrimaryIdentifier]) {

        }
    }
}

- (IBAction)unwindToDropdownViewController:(UIStoryboardSegue *)unwindSegue
{
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    PADropdownViewControllerUnwind *segue = [[PADropdownViewControllerUnwind alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    return segue;
}

-(void) presentViewControllerAtIndex:(NSInteger)index animated:(BOOL)flag completion:(void (^)(void))completion {
    UIViewController * destController =[self.secondaryViewControllers objectAtIndex:index];
    [super presentViewController:destController animated:flag completion:completion];
}

# pragma mark - UITabBarDelegate methods

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if (self.usingStoryboard) { // calls segue programatically if the segue is being used
        NSString * identifier = self.secondaryViewControllerIdentifiers[item.tag];
        [self performSegueWithIdentifier:identifier sender:self];
    } else { // presents the view controller programatically if storyboards are unused
        UIViewController *selectedViewController = self.secondaryViewControllers[item.tag];
        
        // this is just a simple modal presentation. custom behavior must be done through the segue
        [self presentViewController:selectedViewController animated:YES completion:nil];
    }
    
}


@end


# pragma mark - Segues

@implementation PADropdownViewControllerSegue

-(id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        // do custom segue stuff
    }
    return self;
}


-(void) perform
{
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


@implementation PADropdownViewControllerUnwind

-(id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{

    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        // do custom segue stuff
    }
    return self;
}

- (void)perform {
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;

    CGFloat distance = src.view.frame.size.height;
    src.view.transform = CGAffineTransformMakeTranslation(0, 0);
    dst.view.transform = CGAffineTransformMakeTranslation(0, distance);

    [src.view.superview insertSubview:dst.view aboveSubview:src.view];

    [UIView animateWithDuration:0.5
                     animations:^{
                         dst.view.transform = CGAffineTransformMakeTranslation(0, 0);

                     }
                     completion:^(BOOL finished){
                         [dst.view removeFromSuperview];
                         [src dismissViewControllerAnimated:NO completion:NULL];
                     }
     ];
}

@end

