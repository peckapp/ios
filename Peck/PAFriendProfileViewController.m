//
//  PAFriendProfileViewController.m
//  Peck
//
//  Created by John Karabinos on 6/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAFriendProfileViewController.h"
#import "Peer.h"

@interface PAFriendProfileViewController ()

@end

@implementation PAFriendProfileViewController

@synthesize profilePicture, nameLabel, blurbTextView;
@synthesize fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setDetailItem:(id)newDetailItem{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        
        self.nameLabel.text = [self.detailItem valueForKey:@"name"];
        //self.blurbTextView.text = self.detailItem objectForKey:@"
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [blurbTextView setEditable:NO];
    blurbTextView.layer.borderWidth=.5f;
    blurbTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    blurbTextView.layer.cornerRadius = 8;

    [self configureView];
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
