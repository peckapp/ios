//
//  PAMasterViewController.m
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAEventsViewController.h"
#import "PAEventInfoTableViewController.h"
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
#import "PADiningOpportunityCell.h"

#define statusBarHeight 20
#define searchBarHeight 44
#define cellHeight 88
@interface PAEventsViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PAEventsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * cellIdentifier = PAPrimaryIdentifier;
static NSString * nibName = @"PAEventCell";

UITableView * eventsTableView;
UISearchBar * searchBar;

//CGFloat  cellHeight;

//NSCache * imageCache;
BOOL showingDetail;
NSString *searchBarText;
NSDate *today;
NSInteger selectedDay;
CGRect initialTableViewRect;

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
    [[PASyncManager globalSyncManager] updateEventInfoForViewController:self];
    [[PASyncManager globalSyncManager] updateDiningInfo];
    
    NSLog(@"view will appear (events)");
    showingDetail = NO;
    [self registerForKeyboardNotifications];
    searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, searchBarHeight);
    eventsTableView.frame = CGRectMake(0, searchBarHeight, self.view.frame.size.width, (self.view.frame.size.height) - searchBarHeight);
    initialTableViewRect= eventsTableView.frame;
    [self cacheImages];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:YES];
    [self deregisterFromKeyboardNotifications];
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
        searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
        [self.view addSubview:searchBar];
    }
    
    
    if(!self.imageCache){
        self.imageCache = [[NSCache alloc] init];
    }
       
    self.title = @"Events";
    
    if(!eventsTableView){
        eventsTableView = [[UITableView alloc] init];
        [self.view addSubview:eventsTableView];
    }

    eventsTableView.dataSource = self;
    eventsTableView.delegate = self;

    //[[PASyncManager globalSyncManager] updateEventInfo];
    [[PASyncManager globalSyncManager] updateSubscriptions];
    [[PASyncManager globalSyncManager] updatePeerInfo];
    
    [eventsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)cacheImages{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext]];
   
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    for(int i =0; i<[mutableFetchResults count];i++){
        Event* event = mutableFetchResults[i];
        UIImage* img = [self.imageCache objectForKey:[event.id stringValue]];
        if(!img){
            if(event.imageURL){
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:event.imageURL]]]];
            }
            if(img==nil){
                img = [UIImage imageNamed:@"image-placeholder.png"];
            }
            [self.imageCache setObject:img forKey:[event.id stringValue]];
        }
    }
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
    NSPredicate *endDatePredicate = [NSPredicate predicateWithFormat:@"start_date < %@", selectedNight];
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
    [dateComponents setHour:-hours];
    [dateComponents setMinute:-minutes];
    [dateComponents setSecond:-seconds];
    [dateComponents setDay:selectedDay];
    
    NSDate *selectedDayMorning = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
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
    Event * currentEvent = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([currentEvent.type isEqualToString:@"dining"]){
        PADiningOpportunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diningOppCell"];
        if(cell==nil){
            [tableView registerNib:[UINib nibWithNibName:@"PADiningOpportunityCell" bundle:nil] forCellReuseIdentifier:@"diningOppCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"diningOppCell"];
        }
        [self configureDiningCell:cell atIndexPath:indexPath];
        return cell;
    }
    PAEventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}

-(void)configureDiningCell:(PADiningOpportunityCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Event* tempDiningEvent = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = tempDiningEvent.title;
    cell.startTimeLabel.text = [self dateToString:tempDiningEvent.start_date];
    cell.endTimeLabel.text = [self dateToString:tempDiningEvent.end_date];
    
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     //NSLog(@"cell height (height for row): %f",cellHeight);
    Event * tempEvent = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([tempEvent.type isEqualToString:@"dining"]){
        return 44;
    }
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *selectedEvent = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([selectedEvent.type isEqualToString:@"simple"]){
        [self performSegueWithIdentifier:@"showEventDetail" sender:self];
    }
    else if([selectedEvent.type isEqualToString:@"dining"]){
        [self performSegueWithIdentifier:@"showDiningDetail" sender:self];
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
    }else if([[segue identifier] isEqualToString:@"showDiningDetail"]){
        
        showingDetail=YES;
        NSIndexPath *indexPath = [eventsTableView indexPathForSelectedRow];
        NSManagedObject *object;
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //Event *diningEvent=(Event*)object;
        //[[PASyncManager globalSyncManager] updateDiningPlaces:diningEvent forController:[segue destinationViewController]];
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


-(NSString*)dateToString:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSString * timeOfDay = @" AM";
    if(hour>12){
        hour-=12;
        timeOfDay = @" PM";
    }
    
    NSString *minute = [@([components minute]) stringValue];
    if(minute.length==1){
        minute = [@"0" stringByAppendingString:minute];
    }
    
    
    NSString * dateString = [[@(hour) stringValue] stringByAppendingString:@":"];
    dateString = [dateString stringByAppendingString:minute];
    dateString = [dateString stringByAppendingString:timeOfDay];
    return dateString;
    
    
}


- (void)configureCell:(PAEventCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *tempEvent;
    tempEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = tempEvent.title;
    cell.startTime.text = [self dateToString:tempEvent.start_date];
    cell.endTime.text = [self dateToString:tempEvent.end_date];
    
    
    NSString *imageID = [tempEvent.id stringValue];
    UIImage *image = [self.imageCache objectForKey:imageID];
    if(image){
        cell.photoView.image = image;
    }else{
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:tempEvent.imageURL]]]];
            
            UIImage* placeholderImage = [UIImage imageNamed:@"image-placeholder.png"];
            if(img==nil){
                img = placeholderImage;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"image id: %@", imageID);
                
                // change image here
                
                
                
                [self.imageCache setObject:img forKey:imageID];
                cell.photoView.image =img;
                
                //reload the cell to display the image
                //this will be called at most one time for each cell
                //because the image will be loaded into the cache
                //after the first time
                //[eventsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
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

#pragma mark - keyboard notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}


- (void)keyboardWasShown:(NSNotification *)notification {
    if(CGRectEqualToRect(eventsTableView.frame,initialTableViewRect)){
        NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        eventsTableView.frame = CGRectMake(eventsTableView.frame.origin.x, eventsTableView.frame.origin.y, eventsTableView.frame.size.width, eventsTableView.frame.size.height-keyboardSize.height);
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    if(!CGRectEqualToRect(eventsTableView.frame,initialTableViewRect)){
        NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        eventsTableView.frame = CGRectMake(eventsTableView.frame.origin.x, eventsTableView.frame.origin.y, eventsTableView.frame.size.width, eventsTableView.frame.size.height+keyboardSize.height);
    }
    
}

@end
