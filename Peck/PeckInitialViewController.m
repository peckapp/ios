//
//  PeckInitialViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PeckInitialViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PeckInitialViewController ()

@property (strong,nonatomic) NSArray* schoolList;

@end

@implementation PeckInitialViewController

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
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 375);
    loginView.delegate=self;
    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation



- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    //self.profilePictureView.profileID = user.id;
    self.nameLabel.text = user.name;
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        UIViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ConfigureController"];
        
        [self presentViewController:controller animated:YES completion:nil];
        
        //[activityIndicator stopAnimating];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //sets the school string in NSUserDefaults for future reference
    //[[NSUserDefaults standardUserDefaults] setObject:self.schoolList[[self.schoolPicker selectedRowInComponent:0]] forKey:@"school"];
    
    //sets the loginSaved BOOL to YES to avoid login screen in the future
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loginSaved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
