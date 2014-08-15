//
//  PADiningOpportunityViewController.m
//  Peck
//
//  Created by Jonas Luebbers on 8/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADiningOpportunityViewController.h"
#import "PADiningOpportunityCell.h"
#import "PAAssetManager.h"
#import "PAAppDelegate.h"
#import "DiningPlace.h"
#import "MenuItem.h"
#import "PASyncManager.h"

@interface PADiningOpportunityViewController ()

@property (assign, nonatomic) BOOL expanded;

@property (strong, nonatomic) UIView *headerView;
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

    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor whiteColor];

    self.placeLabel = [[UILabel alloc] init];
    self.placeLabel.textColor = [UIColor whiteColor];
    self.placeLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.view addSubview:self.placeLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.frame = self.parentViewController.view.bounds;

    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 88);
    self.placeLabel.frame = CGRectInset(self.headerView.frame, 15, 15);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Nested Table Subview Controller

- (void)expandAnimated:(BOOL)animated
{
    if (!self.expanded) {

        _fetchedResultsController=nil;
        NSError *error=nil;
        if (![self.fetchedResultsController performFetch:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.tableHeaderView = self.headerView;
        self.tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.tableView];
        self.tableView.frame = self.view.bounds;
        self.tableView.contentInset = UIEdgeInsetsMake(256, 0, 0, 0);
        //[self.tableView reloadData];
        //[self.tableView beginUpdates];
        //[self.tableView endUpdates];
        
        self.expanded = YES;
        [[PASyncManager globalSyncManager] updateMenuItemsForOpportunity:self.diningOpportunity andPlace:self.detailItem];
    }
}

- (void)compressAnimated:(BOOL)animated
{
    if (self.expanded) {
        [self.tableView removeFromSuperview];
        self.tableView = nil;

        self.expanded = NO;
    }
}

- (void) setManagedObject:(NSManagedObject *)managedObject parentObject:(NSManagedObject *)parentObject
{
    if (_detailItem != managedObject) {
        _detailItem = (DiningPlace *)managedObject;
    }

    if (_diningOpportunity != parentObject) {
        _diningOpportunity = (Event *)parentObject;
    }

    [self configureView];
}

-(void)configureView{
    if (self.detailItem) {
        self.placeLabel.text = self.detailItem.name;
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
    PADiningOpportunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menu-item-cell-identifier"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PADiningOpportunityCell" bundle:nil] forCellReuseIdentifier:@"menu-item-cell-identifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"menu-item-cell-identifier"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(PADiningOpportunityCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    MenuItem *tempMenuItem = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = tempMenuItem.name;
}

#pragma mark - Fetched Results Controller

-(NSFetchedResultsController *)fetchedResultsController{
    if(_fetchedResultsController){
        return _fetchedResultsController;
    }
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];


    NSMutableArray *predicateArray =[[NSMutableArray alloc] init];
    
    NSLog(@"dining place id: %@", self.detailItem.id);
    NSLog(@"dining opp id: %@", self.diningOpportunity.id);
    
    NSPredicate *fromPlacePredicate = [NSPredicate predicateWithFormat:@"dining_place_id = %@", self.detailItem.id];
    NSPredicate *fromOpportunityPredicate = [NSPredicate predicateWithFormat:@"dining_opportunity_id = %@", self.diningOpportunity.id];

    [predicateArray addObject:fromPlacePredicate];
    [predicateArray addObject:fromOpportunityPredicate];

    NSPredicate *compoundPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [fetchRequest setPredicate:compoundPredicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:_managedObjectContext
                                                             sectionNameKeyPath:nil //this needs to be nil
                                                             cacheName:nil];

    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeMove:
            break;

        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"did change object");

    switch(type)
    {
        case NSFetchedResultsChangeInsert:{
            [self.tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
            [self.tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
        {
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
            [self.tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];

            [self.tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent: (NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


@end
