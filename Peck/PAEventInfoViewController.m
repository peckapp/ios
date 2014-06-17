//
//  PADetailViewController.m
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAEventInfoViewController.h"
#import "PAAppDelegate.h"
#import "Event.h"

@interface PAEventInfoViewController ()
- (void)configureView;
@end

@implementation PAEventInfoViewController
@synthesize fetchedResultsController;
@synthesize detailDescriptionLabel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        NSLog(@"the event: %@", _detailItem);
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"descrip"] description];
        self.eventTitleLabel.text =[[self.detailItem valueForKey:@"eventName"] description];
        
        self.eventPhoto.image = [UIImage imageWithData:[self.detailItem valueForKey:@"photo"]];
        
        
        //cell.imageView.image = [UIImage imageWithData:tempEvent.photo];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self configureView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
