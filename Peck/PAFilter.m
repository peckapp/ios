//
//  PAFilter.m
//  Peck
//
//  Created by Aaron Taylor on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFilter.h"

#define edgeBuffer 20

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

// whether or not the filter is active in selecting a different mode
@property (nonatomic, getter=isActive) BOOL active;
// whether or not the filter is presented on the screen
@property (nonatomic) BOOL presented;

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
        
        self.presented = false;
        
        // loads images for each option
        /*
        self.standard = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-standard" ofType:@"png"]]];
        self.detail = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-detail" ofType:@"png"]]];
        self.subscription = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-subscription" ofType:@"png"]]];
        self.dining = [[CIImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Filter Button-dining" ofType:@"png"]]];
         */
        
        self.standard = [UIImage imageNamed:@"filter_standard.png"];
        self.detail = [UIImage imageNamed:@"filter_detail.png"];
        self.subscription = [UIImage imageNamed:@"filter_subscription.png"];
        self.dining = [UIImage imageNamed:@"filter_dining.png"];
        
        [self addSubview:[[UIImageView alloc] initWithImage:self.standard]];
    }
    
    return self;
}

#pragma mark - Animation

- (void)presentUpwardForMode:(PAFilterMode)mode
{
    if (!self.presented) {
        NSString *keyPath = @"transform.translation.y";
        
        CAKeyframeAnimation *translation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
        translation.delegate = self;
        
        translation.duration = 0.5;
        
        NSMutableArray *values = [NSMutableArray array];
        
        [values addObject:[NSNumber numberWithFloat:0.0]];
        double height = 0 - self.layer.frame.size.height - edgeBuffer;
        [values addObject:[NSNumber numberWithDouble:height]];
        
        translation.values = values;
        
        NSMutableArray * timingFunctions = [NSMutableArray array];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        
        translation.timingFunctions = timingFunctions;
        
        self.presented = true;
        
        [self.layer addAnimation:translation forKey:keyPath];
    } else {
        NSLog(@"WARNING: attempted to present PAFilter when it was already presented");
    }
}

- (void)dismissDownward
{
    if (self.presented) {
        NSString *keyPath = @"transform.translation.y";
        
        CAKeyframeAnimation *translation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
        translation.delegate = self;
        
        translation.duration = 0.5;
        
        NSMutableArray *values = [NSMutableArray array];
        
        [values addObject:[NSNumber numberWithFloat:0.0]];
        double height = self.layer.frame.size.height + edgeBuffer; //[[UIScreen mainScreen] bounds].size.height - self.layer.frame.size.height;
        [values addObject:[NSNumber numberWithDouble:height]];
        
        translation.values = values;
        
        NSMutableArray * timingFunctions = [NSMutableArray array];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        
        translation.timingFunctions = timingFunctions;
        
        self.presented = false;
        
        [self.layer addAnimation:translation forKey:keyPath];
    } else {
        NSLog(@"WARNING: attempted to dismiss PAFilter when it was already dismissed");
    }
    
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    if (self.presented) {
        self.center = CGPointMake(self.center.x, self.center.y - self.layer.frame.size.height - edgeBuffer);
    } else {
        self.center = CGPointMake(self.center.x, self.center.y + self.layer.frame.size.height + edgeBuffer);
    }
}

#pragma mark - User Interaction

// if the touch is on the filter ui element, make the web appear
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.alpha = 1.0; // becomes solid when activated
    
    NSLog(@"touched filter");
    
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
    double height = 60;
    double width = 60;
    double x = [[UIScreen mainScreen] bounds].size.width - width - edgeBuffer;
    double y = [[UIScreen mainScreen] bounds].size.height;
    return CGRectMake(x, y, height, width);
}

@end
