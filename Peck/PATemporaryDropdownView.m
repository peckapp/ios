//
//  PATemporaryDropdownView.m
//  Peck
//
//  Created by Jonas Luebbers on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PATemporaryDropdownView.h"
#import "PAAppDelegate.h"

#define primaryDelay 0.1
#define secondaryDelay 0.2
#define hideDelay 1.5

@interface PATemporaryDropdownView ()

@property (assign, nonatomic) NSInteger pendingHideCount;
@property (nonatomic) CGRect leftButtonFrame;
@property (nonatomic) CGRect rightButtonFrame;

@end

@implementation PATemporaryDropdownView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;

        self.hiddenView = [[UIView alloc] initWithFrame:CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height)];
        self.hiddenView.userInteractionEnabled = YES;
        [self addSubview:self.hiddenView];

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:17.0];
        self.label.text = @"";
        self.label.alpha = 0;
        [self.hiddenView addSubview:self.label];
        
        /*
        self.todayButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.todayButton.userInteractionEnabled=YES;
        self.todayButton.hidden=YES;
        self.todayButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [self.todayButton setTitle:@"Today" forState:UIControlStateNormal];
        self.todayButton.frame = CGRectMake(0, 0, 80, 44);
        self.todayButton.alpha = 0;
        [self.todayButton addTarget:self
                   action:@selector(goToToday)
         forControlEvents:UIControlEventTouchUpInside];
        [self.hiddenView addSubview:self.todayButton];
         */
        
        self.rightButtonFrame = CGRectMake(210, 0, 100, 44);
        self.leftButtonFrame = CGRectMake(10, 0, 100, 44);
        
        self.previousButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self configureButton:self.previousButton withFrame:self.leftButtonFrame];
        self.previousButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.previousButton addTarget:self action:@selector(goToPreviousDay) forControlEvents:UIControlEventTouchUpInside];
        
        self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self configureButton:self.nextButton withFrame:self.rightButtonFrame];
        self.nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.nextButton addTarget:self action:@selector(goToNextDay) forControlEvents:UIControlEventTouchUpInside];

        
    }
    return self;
}

- (void)configureButton:(UIButton*)button withFrame:(CGRect)frame{
    button.userInteractionEnabled=YES;
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    button.frame = frame;
    button.alpha = 0;
    [self.hiddenView addSubview:button];
}

/*
-(void)configureTodayButton:(NSInteger)selectedDay{
    // TODO: Abstract this away from today button specifically, we might want to reuse this class elsewhere
    // TODO: Animate this
    if(selectedDay==0){
        self.todayButton.hidden=YES;
    }else if(selectedDay<0){
        self.todayButton.hidden=NO;
        self.todayButton.frame = self.rightButtonFrame;
    }else if(selectedDay>0){
        self.todayButton.hidden=NO;
        self.todayButton.frame = self.leftButtonFrame;
    }
}
*/

-(void)goToToday{
    //NSLog(@"show today's events");
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate.eventsViewController switchToCurrentDay];
}

- (void)goToNextDay{
    //NSLog(@"show next day's events");
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate.eventsViewController switchToNextDay];
}

- (void)goToPreviousDay{
    //NSLog(@"show previous day's events");
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate.eventsViewController switchToPreviousDay];
}

- (void)temporarilyShowHiddenView
{
    if (self.pendingHideCount <= 0) {
        [self animateIn];
    }
    self.pendingHideCount += 1;
    [self performSelector:@selector(hideHiddenViewAfterDelay) withObject:self afterDelay:hideDelay];
}

- (void)hideHiddenViewAfterDelay
{
    if (self.pendingHideCount == 1) {
        [self hideHiddenView];
    }
    if (self.pendingHideCount > 1) {
        self.pendingHideCount -= 1;
    }
}

- (void)hideHiddenView
{
    self.pendingHideCount = 0;
    [self animateOut];
}

- (void)showHiddenView
{
    [self animateIn];
}

- (void)animateIn
{
    [UIView animateWithDuration:0.2 delay:primaryDelay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.hiddenView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                         self.userInteractionEnabled=YES;
                     }
                     completion:^(BOOL finished){
                     }];

    [UIView animateWithDuration:0.3 delay:secondaryDelay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.label.alpha = 1;
                         //self.todayButton.alpha = 1;
                         self.previousButton.alpha = 1;
                         self.nextButton.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)animateOut
{
    [UIView animateWithDuration:0.2 delay:secondaryDelay - primaryDelay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.hiddenView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         self.userInteractionEnabled=NO;
                     }
                     completion:^(BOOL finished){
                     }];

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.label.alpha = 0;
                         //self.todayButton.alpha = 0;
                         self.previousButton.alpha = 1;
                         self.nextButton.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}

@end
