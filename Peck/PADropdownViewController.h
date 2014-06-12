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

@protocol PADropdownViewControllerDelegate; //allows delegate to be referenced in interface

@interface PADropdownViewController : UIViewController

// viewcontroller that displays the primary content
@property (strong, nonatomic) UIViewController * primaryViewController;

// array of viewcontrollers that drop down on button clicks to display their content
// order of the elements in the array determines their presentation order, left to right.
@property (strong, nonatomic) NSArray * secondaryViewControllers;
- (void)setSecondaryViewControllers:(NSArray *)secondaryViewControllers animated:(BOOL)animated;

// points temporarily to the viewcontroller that is active
// this could be either the primary or one of the secondaries, depending on the current state
@property (weak, nonatomic) UIViewController * activeViewController;
// the location of the activeViewController in the secondaryViewControllers array. nil if primary is active
@property (nonatomic) NSUInteger * activeIndex;

// Contains all the icons at the top of the screen,
// handling touches to those items that cause their associated views to drop down
@property (nonatomic,readonly) UITabBar * tabBar;

//
@property(nonatomic, assign) id<PADropdownViewControllerDelegate> delegate;

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


// *****************************************************
// the below delegate methods were copied in from UITabBarController and are likely unnecessary. Just temporarily kept around for reference.
// *****************************************************
- (void)dropdownController:(PADropdownViewController *)dropdownController willBeginCustomizingViewControllers:(NSArray *)viewControllers;
- (void)dropdownController:(PADropdownViewController *)dropdownController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;
- (void)dropdownController:(PADropdownViewController *)dropdownController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;

- (NSUInteger)dropdownControllerSupportedInterfaceOrientations:(PADropdownViewController *)dropdownController;
- (UIInterfaceOrientation)dropdownControllerPreferredInterfaceOrientationForPresentation:(PADropdownViewController *)dropdownController;

- (id <UIViewControllerInteractiveTransitioning>)dropdownController:(PADropdownViewController *)dropdownController
                      interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController;

- (id <UIViewControllerAnimatedTransitioning>)dropdownController:(PADropdownViewController *)dropdownController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC ;

@end

// this allows the relationships to be defined on a storyboard
@interface PADropdownViewControllerSegue : UIStoryboardSegue

// copied in from SWRevealViewController
@property (strong) void(^performBlock)( PADropdownViewControllerSegue* segue, UIViewController* svc, UIViewController* dvc );

@end

