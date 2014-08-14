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
    if(managedObject){
        self.
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
