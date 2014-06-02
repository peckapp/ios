//
//  PeckLoadingViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/12/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PeckLoadingViewController.h"

@interface PeckLoadingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIButton *begin;

-(void) loadConfig;

@end

@implementation PeckLoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.begin setEnabled:NO];
    [self.progress setProgress:0.0 animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [self loadConfig];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadConfig {
    // this is where the configuration files will be brought in
    // des't do anything meaningful or work as intended currently
    [self.progress setProgress:1.0 animated:YES];
    for (int i = 0; i <= 5; i++) {
        self.status.text = [NSString stringWithFormat:@"loading in part %d",i];
        //[self.progress setProgress:(i/5.0) animated:YES];
        [NSThread sleepForTimeInterval:.05];
    }
    [self.begin setEnabled:YES];
}

@end
