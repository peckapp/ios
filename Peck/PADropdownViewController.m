//
//  PADropdownViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/11/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADropdownViewController.h"

@interface PADropdownViewController ()


@property (nonatomic) BOOL animated;
// the common name between the storyboard identifiers and the title properties of the secondaryViewControllers
@property (nonatomic) NSArray * secondaryIdentifiers;

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
        // what this should really do is try to access the connected manual triggered segues from the storyboard, but not sure how
        tabBar.items = @[[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:1],
                         [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:2],
                         [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:3]];
    } else {
        // does the necessary setup for each viewcontroller, retreiving tabBarItems and passing it the managedObject Context
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
    }
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

# pragma mark - UITabBarDelegate methods

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    UIViewController *selectedViewController = self.secondaryViewControllers[item.tag];
    [self performSegueWithIdentifier:selectedViewController.restorationIdentifier sender:self];
}

# pragma mark - PADropdownViewControllerDelegate methods



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
    [self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:nil];
}

@end