//
//  PAFriendProfileViewController.m
//  Peck
//
//  Created by John Karabinos on 6/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFriendProfileViewController.h"

@interface PAFriendProfileViewController ()

@end

@implementation PAFriendProfileViewController

@synthesize profilePicture, nameLabel, blurbTextView;

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
    profilePicture.image = [UIImage imageNamed:@"Silhouette.png"];
    [blurbTextView setEditable:NO];
    blurbTextView.layer.borderWidth=.5f;
    blurbTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    blurbTextView.layer.cornerRadius = 8;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}
@end
