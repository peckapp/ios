//
//  PADiningOpportunityViewController.m
//  Peck
//
//  Created by Jonas Luebbers on 8/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADiningOpportunityViewController.h"
#import "PAAssetManager.h"

@interface PADiningOpportunityViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UILabel *placeLabel;

@end

PAAssetManager *assetManager;

@implementation PADiningOpportunityViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)viewDidLoad {
    [super viewDidLoad];

    assetManager = [PAAssetManager sharedManager];

    self.view.backgroundColor = [assetManager darkColor];

    self.placeLabel = [[UILabel alloc] init];
    self.placeLabel.textColor = [UIColor whiteColor];
    self.placeLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:self.placeLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.placeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 88);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Nested Table Subview Controller

- (void)expandAnimated:(BOOL)animated
{

}

- (void)compressAnimated:(BOOL)animated
{

}

- (void) setManagedObject:(NSManagedObject *)managedObject
{
    if (_detailItem != managedObject) {
        _detailItem = managedObject;
        
        [self configureView];
    }
}

-(void)configureView{
    if (self.detailItem) {
        
    }
}

- (UIView *)viewForBackButton
{
    return self.view;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    // return [[_fetchedResultsController sections] count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
