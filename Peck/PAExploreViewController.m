//
//  PAFeedTableViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAExploreViewController.h"
#import "PAAppDelegate.h"
#import "PAExploreCell.h"
#import "PAExploreInfoViewController.h"
#import "Explore.h"
#import "PASyncManager.h"
#import "PAAssetManager.h"
#import "UIImageView+AFNetworking.h"
#import "PATemporaryHeader.h"
#import "PAUtils.h"

#define cellHeight 380

@interface PAExploreViewController ()

@property (strong) UITableView *tableView;
@property (strong) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UISearchBar* searchBar;

@end


@implementation PAExploreViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * cellIdentifier = PAExploreIdentifier;
static NSString * nibName = @"PAExploreCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fetchedResultsController=nil;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    self.title = @"Explore";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // wrapping the tableView in a UITableViewController allows for the UIRefreshControl to be simpy added using apple's supported APIs
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;

    self.tableView.contentInset = UIEdgeInsetsMake(9, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [[PASyncManager globalSyncManager] updateExploreWithCallback:nil];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    _searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    _searchBar.placeholder = @"Search";
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 54)];
    [headerView addSubview:_searchBar];
    self.tableView.tableHeaderView = _searchBar;
    
    // NSLog(@"Finished viewDidLoad (PAExploreTableViewController)");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor blackColor]];
}

-(void)refresh {
    [[PASyncManager globalSyncManager] updateExploreWithCallback:^(BOOL sucess) {
        [self.refreshControl endRefreshing];
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _fetchedResultsController=nil;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Fetched results controller could not perform fetch");
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cacheImagesPastCurrentIndexPath:(NSIndexPath*)indexPath {
    // TODO: implement this method to pre-load images as the user scrolls
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PAExploreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Configure cell by loading a nib.
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    [self cacheImagesPastCurrentIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PAExploreCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundView = [[PAAssetManager sharedManager] createShadowWithFrame:cell.frame];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    cell.parentViewController = self;

    // Common configurations
    Explore *tempExplore = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.descriptionLabel.text = tempExplore.explore_description;
    cell.titleLabel.text = tempExplore.title;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mma  EEEE MMM dd"];// here set format which you want...
    cell.dateLabel.text = [dateFormatter stringFromDate:tempExplore.start_date];
    cell.exploreID = [tempExplore.id integerValue];
    cell.category = tempExplore.category;
    
    // Announcement configurations
    if([tempExplore.category isEqualToString:@"announcement"]){
        cell.contextLabel.text = @" Announcement";
    }
    // Athletic Event configuration
    else if([tempExplore.category isEqualToString:@"athletic"]){
        cell.contextLabel.text = @" Athletic Event";    }
    // General Event configuration
    else{
        cell.contextLabel.text = @" Event";
    }
    
    if(tempExplore.imageURL){
        NSURL* imageURL = [NSURL URLWithString:tempExplore.imageURL];
        UIImage* image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
    
        if(image){
            cell.photoView.image = image;
        } else {
            [cell.photoView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:imageURL]
                                  placeholderImage:[[PAAssetManager sharedManager] greyBackground]
                                           success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image){
                                               [UIView transitionWithView:cell.photoView
                                                                 duration:.4f
                                                                  options:UIViewAnimationOptionTransitionCrossDissolve
                                                               animations:^{
                                                                   cell.photoView.image = image;
                                                               } completion:nil];
                                           }
                                           failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error){
                                               NSLog(@"failed to get image");
                                           }];
        }
    } else {
        cell.photoView.image = [[PAAssetManager sharedManager] imagePlaceholder];
    }
    
    if ([tempExplore.category isEqualToString:@"event"] || [tempExplore.category isEqualToString:@"athletic"]) {
        cell.attendButton.hidden = NO;
    } else {
        cell.attendButton.hidden = YES;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 60);
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:CGPointMake(self.tableView.tableHeaderView.frame.size.width, 20)]; // I do this because I'm in landscape mode
    [self.tableView.tableHeaderView addSubview:spinner];
     */
    
    [self performSegueWithIdentifier:@"presentInfo" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)unwindToExploreController:(UIStoryboardSegue *)unwindSegue
{
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"presentInfo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSLog(@"segue destination: %@", [segue destinationViewController]);
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSString * eventString = @"Explore";
    NSEntityDescription *entity = [NSEntityDescription entityForName:eventString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"weight" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if(!([self.searchBar.text isEqualToString:@""] || self.searchBar.text==nil)){
        NSPredicate* searchPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", @"title", self.searchBar.text];
        [fetchRequest setPredicate:searchPredicate];
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    /*
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}*/
    
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PAExploreCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
