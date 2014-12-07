//
//  PAFeedInfoViewController.m
//  Peck
//
//  Created by John Karabinos on 6/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAExploreInfoViewController.h"
#import "PAAssetManager.h"
#import "UIImageView+AFNetworking.h"

@interface PAExploreInfoViewController ()

- (void)setDetailItem:(id)newDetailItem;

@end

@implementation PAExploreInfoViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize messageTextView;
@synthesize messagePhoto;


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        NSLog(@"configure the detail item");
        NSURL *imgUrl = [NSURL URLWithString:[self.detailItem valueForKey:@"imageURL"]];
        [self.messagePhoto setImageWithURL:imgUrl
                          placeholderImage:[[PAAssetManager sharedManager] greyBackground]];
        self.messageTextView.text = [self.detailItem valueForKey:@"explore_description"];
        
        self.eventTitle.text = [[self.detailItem valueForKey:@"title"] description];
        self.location.text = [[self.detailItem valueForKey:@"location"] description];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy h:mm a"];
        [self.date setText:[dateFormatter stringFromDate:[self.detailItem valueForKey:@"start_date"]]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [messageTextView setEditable:NO];
    
    [self configureView];
    
    // Do any additional setup after loading the view.
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

@end
