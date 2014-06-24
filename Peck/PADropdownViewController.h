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

@protocol PADropdownViewControllerDelegate; //allows delegate to be referenced in interface

@interface PADropdownViewController : UIViewController <PACoreDataProtocol, PADropdownBarDelegate>

// viewcontroller that displays the primary content
@property (nonatomic) UIViewController * primaryViewController;

// array of viewcontrollers that drop down on button clicks to display their content
// order of the elements in the array determines their presentation order, left to right.
// These viewControllers MUST have these properties:
//  - custom PADropdownViewControllerSegues pointing to them in the storyboard
//  - title properties set and their associates segues configured with identifiers containing the same string
//  - tabBarItem properties set with UITabBarItems
@property (nonatomic) NSArray * secondaryViewControllers;

// points temporarily to the viewcontroller that is active
// this could be either the primary or one of the secondaries, depending on the current state
@property (nonatomic) UIViewController * activeViewController;

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

