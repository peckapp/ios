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
        
    }
    // does the necessary setup for each viewcontroller, retreiving tabBarItems and passing it the managedObject Context
    NSLog(@"Instantiating secondaryViewControllers for the PAPropdownViewController from the storyboard based on secondaryViewControllerIdentifiers");
    NSMutableArray * tempTabBarItems = [NSMutableArray arrayWithCapacity:self.secondaryViewControllers.count];
    
    [self.secondaryViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIViewController *viewController = (UIViewController*)obj;
        if ([viewController conformsToProtocol:@protocol(PACoreDataProtocol)]) { // passes managedObjectContext if viewController conforms to protocol
            
            UIViewController <PACoreDataProtocol> * cdViewController = (UIViewController <PACoreDataProtocol> *)viewController;
            cdViewController.managedObjectContext = self.managedObjectContext;
            
        } else if ([viewController isMemberOfClass:[UINavigationController class]]) { // passes mOC to topViewController of NavController if possible
            
            UIViewController * topViewController = ((UINavigationController*)viewController).topViewController;
            
            if ([topViewController conformsToProtocol:@protocol(PACoreDataProtocol)]) {
                UIViewController <PACoreDataProtocol> * cdViewController = (UIViewController <PACoreDataProtocol> *)topViewController;
                cdViewController.managedObjectContext = self.managedObjectContext;
            }
        }
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

# pragma mark - PADropdownViewControllerDelegate methods


# pragma mark - Custom unwind segue
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    PADropdownViewControllerUnwind *segue = [[PADropdownViewControllerUnwind alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    return segue;
}


@end


# pragma mark - PADropdownViewController custom Segue methods

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
    // make whatever view controller calls are necessary to perform the transition you want

    
    // this is a simple transition, needs to be customized further
    /*
    [self.sourceViewController presentViewController:self.destinationViewController
                                            animated:YES
                                          completion:nil];
    */

    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;

    CGFloat distance = src.view.frame.size.height;
    src.view.transform = CGAffineTransformMakeTranslation(0, 0);
    dst.view.transform = CGAffineTransformMakeTranslation(0, 0);

    [src.view.superview insertSubview:dst.view belowSubview:src.view];

    [UIView animateWithDuration:0.5
                     animations:^{
                         src.view.transform = CGAffineTransformMakeTranslation(0, distance);

                     }
                     completion:^(BOOL finished){
                         [dst.view removeFromSuperview];
                         [src presentViewController:dst animated:NO completion:NULL];
                     }
     ];

    ((UIViewController <PACoreDataProtocol> *)self.destinationViewController).managedObjectContext
        = ((UIViewController <PACoreDataProtocol> *)self.sourceViewController).managedObjectContext;

}

@end


@implementation PADropdownViewControllerUnwind

- (void)perform {
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;

    CGFloat distance = src.view.frame.size.height;
    src.view.transform = CGAffineTransformMakeTranslation(0, 0);
    dst.view.transform = CGAffineTransformMakeTranslation(0, 0);

    [src.view.superview insertSubview:dst.view belowSubview:src.view];

    [UIView animateWithDuration:0.5
                     animations:^{
                         src.view.transform = CGAffineTransformMakeTranslation(0, distance);

                     }
                     completion:^(BOOL finished){
                         [dst.view removeFromSuperview];
                         [src presentViewController:dst animated:NO completion:NULL];
                     }
     ];
}

@end

