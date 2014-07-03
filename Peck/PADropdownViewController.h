//
//  PADropdownViewController.h
//  Peck
//
//  Created by Aaron Taylor on 6/11/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//
//  This class provides the functionality of radio buttons at the top of the screen
//  that cause modal views to pop down over the primary content.
//  Unlike a UITabBarController, there is a primary view that sits at the base of this setup,
//  and the dropdown views sit over that primary view to perform secondary tasks, until they
//  are dismissed by tapping on their icon once again.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PACoreDataProtocol.h"
#import "PADropdownBar.h"
#import "PAFilter.h"

@protocol PADropdownViewControllerDelegate; //allows delegate to be referenced in interface

@interface PADropdownViewController : UIViewController <PACoreDataProtocol, PADropdownBarDelegate, PAFilterDelegate>

// strings that indicate the storyboard identifiers of the various views for this controller
@property (nonatomic) NSString * primaryViewControllerIdentifier;
@property (nonatomic) NSArray * secondaryViewControllerIdentifiers;

// Contains all the icons at the top of the screen,
// handling touches to those items that cause their associated views to drop down
@property (nonatomic) PADropdownBar * dropdownBar;

// acts as its own delegate
@property(nonatomic, assign) id<PADropdownViewControllerDelegate> delegate;

// the core data managed object context to be passed to the child viewControllers
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


@protocol PADropdownViewControllerDelegate <NSObject>

@optional
// delegate methods for the presentation of a dropdown over the primary content view
- (BOOL)dropdownController:(PADropdownViewController *)dropdownController shouldPresentDropdown:(UIViewController *)viewController;
- (void)dropdownController:(PADropdownViewController *)dropdownController didPresentDropdown:(UIViewController *)viewController;

// delegate methods for the dismissal of a presented dropdown
- (BOOL)dropdownController:(PADropdownViewController *)dropdownController shouldDismissDropdown:(UIViewController *)viewController;
- (void)dropdownController:(PADropdownViewController *)dropdownController didDismissDropdown:(UIViewController *)viewController;

// delegate methods for switching between active dropdowns
- (BOOL)dropdownController:(PADropdownViewController *)dropdownController shouldSwitchToDropdown:(UIViewController *)viewController;
- (void)dropdownController:(PADropdownViewController *)dropdownController didSwitchToDropdown:(UIViewController *)viewController;

- (NSUInteger)dropdownControllerSupportedInterfaceOrientations:(PADropdownViewController *)dropdownController;
- (UIInterfaceOrientation)dropdownControllerPreferredInterfaceOrientationForPresentation:(PADropdownViewController *)dropdownController;

- (id <UIViewControllerAnimatedTransitioning>)dropdownController:(PADropdownViewController *)parentController
              animationControllerForTransitionFromViewController:(UIViewController *)previousViewController
                                                toViewController:(UIViewController *)nextViewController;
@end

