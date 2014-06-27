//
//  PAMasterViewController.m
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAEventsViewController.h"
#import "PAEventInfoViewController.h"
#import "PAPostViewController.h"
#import "PAPecksViewController.h"
#import "PAAppDelegate.h"
#import "Event.h"
#import "PASessionManager.h"
#import "PAEventCell.h"
#import "PADropdownViewController.h"
#import "PAEvents.h"
#import "PASyncManager.h"
#import "PAImageManager.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface PAEventsViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PAEventsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
static NSString *cellIdentifier = PAAddIdentifier;
static NSString *nibName = @"PAEventCell";
UITableView *eventsTableView;
UISearchBar * searchBar;
int titleThickness;
int searchBarThickness;
int lastCurrentHeight;
CGRect initialSearchBarRect;
CGRect initialTableViewRect;
NSCache *imageCache;
BOOL searching;
BOOL showingDetail;
NSString *searchBarText;
- (void)awakeFromNib
{
    [super awakeFromNib];
    

}

-(void)viewDidDisappear:(BOOL)animated{
    if(!showingDetail){
        searching=NO;
        [eventsTableView reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    showingDetail=NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    searching=NO;
    showingDetail=NO;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    lastCurrentHeight=0;
    if(!searchBar){
        titleThickness=44;
        searchBarThickness = 40;
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,searchBarThickness)];
        initialSearchBarRect=searchBar.frame;
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
        [self.view addSubview:searchBar];
    }
    
    
    if(!imageCache){
        imageCache = [[NSCache alloc] init];
    }
       
    self.title = @"Events";
    
    if(!eventsTableView){
        int tableViewY = searchBarThickness;
        eventsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, 320, (self.view.frame.size.height)-tableViewY-20)];
        //20 is the thickness of the bar with time and battery
        initialTableViewRect = eventsTableView.frame;
        NSLog(@"view height: %f", self.view.frame.size.height);
        NSLog(@"table view height: %f", (self.view.frame.size.height)-tableViewY);
        [self.view addSubview:eventsTableView];
    }
    eventsTableView.dataSource = self;
    eventsTableView.delegate = self;

    [[PASyncManager globalSyncManager] updateEventInfo];
    
    [eventsTableView reloadData];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetched Results controller

-(NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController!=nil){
        return _fetchedResultsController;
    }
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSString * eventString = @"Event";
    NSEntityDescription *entity = [NSEntityDescription entityForName:eventString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
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

-(NSFetchedResultsController *)searchFetchedResultsController{
    if(_searchFetchedResultsController)
        return _searchFetchedResultsController;
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSString * eventString = @"Event";
    NSEntityDescription *entity = [NSEntityDescription entityForName:eventString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"title";
    NSString *attributeValue = searchBarText;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@",
                              attributeName, attributeValue];
    // the [c] dismisses case sensitivity
    NSLog(@"creating the new predicate");
    NSLog(@"search bar text: %@", searchBarText);
    
    [fetchRequest setPredicate:predicate];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_date" ascending:YES];
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
    self.searchFetchedResultsController = aFetchedResultsController;
    
    return _searchFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [eventsTableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [eventsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [eventsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"did change object");
    UITableView *tableView = eventsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent: (NSFetchedResultsController *)controller
{
    [eventsTableView endUpdates];
}

#pragma mark - Table View

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int currentHeight = (int)[[eventsTableView.layer presentationLayer] bounds].origin.y;
    if(currentHeight>lastCurrentHeight && currentHeight>0){
        if((([_fetchedResultsController.fetchedObjects count]*44>initialTableViewRect.size.height+searchBarThickness)&& !searching) || (([_searchFetchedResultsController.fetchedObjects count]*44>initialTableViewRect.size.height) && searching)){
            // only scroll the scroll bar up if the number of events goes off screen
            int tempCurrentHeight=currentHeight;
            if(currentHeight>searchBarThickness){
                tempCurrentHeight=searchBarThickness;
            }
            CGRect tempSearchRect = initialSearchBarRect;
            tempSearchRect.origin.y = initialSearchBarRect.origin.y -tempCurrentHeight;
            searchBar.frame=tempSearchRect;
            CGRect tempTableViewRect = initialTableViewRect;
            tempTableViewRect.origin.y = initialTableViewRect.origin.y - tempCurrentHeight;
            tempTableViewRect.size.height = initialTableViewRect.size.height+tempCurrentHeight;
            eventsTableView.frame=tempTableViewRect;
        }
        
    }
    else if(currentHeight<lastCurrentHeight){
        if(currentHeight<=0){
            if(!CGRectEqualToRect(searchBar.frame ,initialSearchBarRect)){
            for(int i=0; i<=searchBarThickness;i++){
                CGRect tempSearchRect = initialSearchBarRect;
                tempSearchRect.origin.y = initialSearchBarRect.origin.y +i -searchBarThickness;
                searchBar.frame=tempSearchRect;
                CGRect tempTableViewRect = initialTableViewRect;
                tempTableViewRect.origin.y = initialTableViewRect.origin.y +i-searchBarThickness;
                tempTableViewRect.size.height = initialTableViewRect.size.height-i+searchBarThickness;
                eventsTableView.frame=tempTableViewRect;
            }
            }
        }
    }
    
    lastCurrentHeight=currentHeight;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(!searching)
       return [[_fetchedResultsController sections] count];
    else
        return [[_searchFetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!searching){
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    }
    else{
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_searchFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PAEventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Configure cell by loading a nib.
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    // Return cell size.
    return cell.frame.size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView==eventsTableView){
        [self performSegueWithIdentifier:@"showEventDetail" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEventDetail"]) {
        showingDetail=YES;
        NSIndexPath *indexPath = [eventsTableView indexPathForSelectedRow];
        NSManagedObject *object;
        if(!searching)
            object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        else
            object = [[self searchFetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}



/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(PAEventCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *tempEvent;
    if(!searching)
        tempEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    else
        tempEvent =[self.searchFetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = tempEvent.title;
    NSString *imageID = tempEvent.id;
    UIImage *image = [imageCache objectForKey:imageID];
    if(image){
        // TODO: replace this URL with SharedClient URL and event image url
        [cell.photoView setImageWithURL:[NSURL URLWithString:@"http://thor.peckapp.com:3500/images/event.png"]placeholderImage:image];
    }else{
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData *data = [[PAImageManager imageManager] ReadImage:tempEvent.title];
            //NSData *data = tempEvent.photo;
            UIImage *image = [UIImage imageWithData:data];
            if(!image){
                // TODO: replace this to cache image from server
                image = [UIImage imageNamed:@"image-placeholder.png"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"image id: %@", imageID);
                [imageCache setObject:image forKey:imageID];
                cell.photoView.image =image;
                //reload the cell to display the image
                //this will be called at most one time for each cell
                //because the image will be loaded into the cache
                //after the first time
                [eventsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
}

#pragma mark - Search Bar Delegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Text did change");
    if([searchText isEqualToString:@""]){
        searching=NO;
        searchBar.text=nil;
        [eventsTableView reloadData];
        NSLog(@"User cancelled search");
    }else{
        NSLog(@"use the search fetch controller");
        _searchFetchedResultsController=nil;
        searchBarText = searchText;
        searching=YES;
        NSError *error = nil;
        if (![self.searchFetchedResultsController performFetch:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    
        [eventsTableView reloadData];
        lastCurrentHeight = 0;
        
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    searching=NO;
    searchBar.text=nil;
    [eventsTableView reloadData];
    NSLog(@"User cancelled search");
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}

- (IBAction)yesterdayButton:(id)sender {
    NSLog(@"Yesterday");
}

- (IBAction)todayButton:(id)sender {
    NSLog(@"Today");
}

- (IBAction)tomorrowButton:(id)sender {
    NSLog(@"Tomorrow");
}
@end
