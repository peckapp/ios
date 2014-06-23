//
//  PAFilter.m
//  Peck
//
//  Created by Aaron Taylor on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFilter.h"

@interface PAFilter() {
    
}

@property (nonatomic, retain) NSMutableArray * selections;

/*
@property (nonatomic, retain) CIImage * standard;
@property (nonatomic, retain) CIImage * detail;
@property (nonatomic, retain) CIImage * subscription;
@property (nonatomic, retain) CIImage * dining;
 */

@property (nonatomic, retain) UIImage * standard;
@property (nonatomic, retain) UIImage * detail;
@property (nonatomic, retain) UIImage * subscription;
@property (nonatomic, retain) UIImage * dining;

@property (nonatomic, getter=isActive) BOOL active;

@end

@implementation PAFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // TODO: make starting rect dynamically adjustable for different screen sizes
        CGRect frame = [self startingRect];
        
        self.frame = frame;
        //[self.layer setFrame:frame]; // possibly unnecessary
        
        self.alpha = 0.75; // slightly transparent when unactivated
        
        // loads images for each option
        /*
        self.standard = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-standard" ofType:@"png"]]];
        self.detail = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-detail" ofType:@"png"]]];
        self.subscription = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-subscription" ofType:@"png"]]];
        self.dining = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-dining" ofType:@"png"]]];
         */
        
        self.standard = [UIImage imageNamed:@"Filter Button-standard.png"];
        self.detail = [UIImage imageNamed:@"Filter Button-detail.png"];
        self.subscription = [UIImage imageNamed:@"Filter Button-subscription.png"];
        self.dining = [UIImage imageNamed:@"Filter Button-dining.png"];
        
        [self addSubview:[[UIImageView alloc] initWithImage:self.standard]];
    }
    
    return self;
}

- (void)presentUpwardForMode:(PAFilterMode)mode
{
    NSString *keyPath = @"transform.translation.y";
    
    CAKeyframeAnimation *translation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    
    translation.duration = 0.5;
    translation.autoreverses = true;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSNumber numberWithFloat:0.0]];
    double height = 0 - self.layer.frame.size.height;
    [values addObject:[NSNumber numberWithDouble:height]];
    
    translation.values = values;
    
    NSMutableArray * timingFunctions = [NSMutableArray array];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    translation.timingFunctions = timingFunctions;
    
    [self.layer addAnimation:translation forKey:keyPath];
}

- (void)dismissDownward
{
    NSString *keyPath = @"transform.translation.y";
    
    CAKeyframeAnimation *translation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    
    translation.duration = 0.5;
    translation.autoreverses = true;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSNumber numberWithFloat:0.0]];
    double height = self.layer.frame.size.height; //[[UIScreen mainScreen] bounds].size.height - self.layer.frame.size.height;
    [values addObject:[NSNumber numberWithDouble:height]];
    
    translation.values = values;
    
    NSMutableArray * timingFunctions = [NSMutableArray array];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    translation.timingFunctions = timingFunctions;
    
    [self.layer addAnimation:translation forKey:keyPath];
}

// if the touch is on the filter ui element, make the web appear
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.alpha = 1.0; // becomes solid when activated
    
    [self setNeedsDisplay]; // let the system know to update the view, probably want to do this with animation instead
}

// if the web is active, handle the touches
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isActive]) {
        // check which web item is being selected, animate as necessary
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isActive]) {
        // if another option was selected:
        // call methods in superview to update table view cells accordingly
    }
    
    self.alpha = 0.75; // becomes transparent after selection finishes
    self.active = false;
}

# pragma mark - Utiliy methods

- (CGRect) startingRect
{
    return CGRectMake(250, 500, 60, 60);
}

@end
