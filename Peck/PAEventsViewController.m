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

#define statusBarHeight 20
#define searchBarHeight 40

@interface PAEventsViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PAEventsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * cellIdentifier = PAPrimaryIdentifier;
static NSString * nibName = @"PAEventCell";

UITableView *eventsTableView;
UISearchBar * searchBar;

CGFloat cellHeight;

NSCache * imageCache;
BOOL showingDetail;
NSString *searchBarText;
NSDate *today;
NSInteger selectedDay;

- (void)awakeFromNib
{
    [super awakeFromNib];
    

}

-(void)viewDidDisappear:(BOOL)animated{
    if(!showingDetail){
        [eventsTableView reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"view will appear");
    showingDetail = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"View did load (events)");
    selectedDay=0;
    showingDetail = NO;
    NSError * error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    if(!searchBar){
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, searchBarHeight)];
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
        [self.view addSubview:searchBar];
    }
    
    
    if(!imageCache){
        imageCache = [[NSCache alloc] init];
    }
       
    self.title = @"Events";
    
    if(!eventsTableView){
        int tableViewY = searchBarHeight;
        eventsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, self.view.frame.size.width, (self.view.frame.size.height) - tableViewY - statusBarHeight)];
        NSLog(@"view height: %f", self.view.frame.size.height);
        NSLog(@"table view height: %f", (self.view.frame.size.height) - tableViewY);
        [self.view addSubview:eventsTableView];
    }

    eventsTableView.dataSource = self;
    eventsTableView.delegate = self;

    // Get the size of the cells
    UITableViewCell * cell = [eventsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Configure cell by loading a nib.
        [eventsTableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [eventsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    cellHeight = cell.frame.size.height;

    [[PASyncManager globalSyncManager] updateEventInfo];
    [[PASyncManager globalSyncManager] updatePeerInfo];
    
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
    
    
    NSMutableArray *predicateArray =[[NSMutableArray alloc] init];
    if(searchBarText){
        NSString *attributeName = @"title";
        NSString *attributeValue = searchBarText;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@",
                                  attributeName, attributeValue];
        // the [c] dismisses case sensitivity
        [predicateArray addObject:predicate];
    }
    
    
    NSDate *selectedMorning = [self updateDate];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];
    NSDate *selectedNight =[[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:selectedMorning options:0];
    
    NSPredicate *startDatePredicate = [NSPredicate predicateWithFormat:@"start_date > %@", selectedMorning];
    NSPredicate *endDatePredicate = [NSPredicate predicateWithFormat:@"end_date < %@", selectedNight];
    NSLog(@"the current date: %@", [NSDate date]);
    
    [predicateArray addObject:startDatePredicate];
    [predicateArray addObject:endDatePredicate];
    NSPredicate *compoundPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [fetchRequest setPredicate:compoundPredicate];

    
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
    self.fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}


-(NSDate *)updateDate{
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond  fromDate:[NSDate date]];
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setHour:-hours-4];
    [dateComponents setMinute:-minutes];
    [dateComponents setSecond:-seconds];
    [dateComponents setDay:selectedDay];
    
    NSDate *selectedDayMorning = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    NSLog(@"today (instance): %@", selectedDayMorning);
    return selectedDayMorning;
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
            //Event *tempEvent = (Event *)anObject;
            [[PASyncManager globalSyncManager] deleteEvent: ((Event*)anObject).id];
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
    /*
    int currentHeight = (int)[[eventsTableView.layer presentationLayer] bounds].origin.y;
    if(currentHeight>lastCurrentHeight && currentHeight>0){
        if((([_fetchedResultsController.fetchedObjects count] * 88 > eventsTableView.frame.size.height + searchBarThickness)&& !searching) || (([_searchFetchedResultsController.fetchedObjects count] * 44 > eventsTableView.frame.size.height) && searching)) {

            // only scroll the scroll bar up if the number of events goes off screen
            int tempCurrentHeight = currentHeight;
            if(currentHeight > searchBarHeight){
                tempCurrentHeight = searchBarHeight;
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
    */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
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
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == eventsTableView){
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
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
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
        tempEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.titleLabel.text = tempEvent.title;
    NSString *imageID = [tempEvent.id stringValue];
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
        searchBar.text = nil;
        searchBarText=nil;
        _fetchedResultsController=nil;
        [self reloadTheView];
        NSLog(@"User cancelled search");
    }else{
        NSLog(@"use the search fetch controller");
        _fetchedResultsController = nil;
        searchBarText = searchText;
        NSError * error = nil;
        if (![self.fetchedResultsController performFetch:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    
        [eventsTableView reloadData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    searchBar.text = nil;
    searchBarText=nil;
     _fetchedResultsController = nil;
    [self reloadTheView];
    NSLog(@"User cancelled search");
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}

- (IBAction)yesterdayButton:(id)sender {
    NSLog(@"Yesterday");
    selectedDay--;
    _fetchedResultsController = nil;
    [self reloadTheView];
}

- (IBAction)todayButton:(id)sender {
    selectedDay=0;
    _fetchedResultsController = nil;
    NSLog(@"Today");
    [self reloadTheView];
}

- (IBAction)tomorrowButton:(id)sender {
    selectedDay++;
    _fetchedResultsController = nil;
    NSLog(@"Tomorrow");
    [self reloadTheView];
}

-(void)reloadTheView{
    NSError *error=nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [eventsTableView reloadData];
}
@end
