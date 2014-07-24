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
#import "UIImage+ImageEffects.h"

#define statusBarHeight 20
#define searchBarHeight 44

@interface PAEventsViewController ()



@end

@implementation PAEventsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * cellIdentifier = PAPrimaryIdentifier;
static NSString * nibName = @"PAEventCell";

UISearchBar * searchBar;

BOOL showingDetail;
NSString *searchBarText;
NSDate *today;
NSInteger selectedDay;
CGRect initialTableViewRect;

- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"View did load (events)");
    if(!self.imageCache){
        self.imageCache = [[NSCache alloc] init];
    }
    self.title = @"Events";
    
    selectedDay=0;
    showingDetail = NO;
    [self reloadTheView];
    if(!searchBar){
        searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
        [self.view addSubview:searchBar];
    }
    
    
   
    
    if(!self.tableView){
        self.tableView = [[UITableView alloc] init];
        [self.view addSubview:self.tableView];
    }

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    UIView * backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor blackColor];
    [self.tableView setBackgroundView:backView];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [[PASyncManager globalSyncManager] updateSubscriptions];
    [[PASyncManager globalSyncManager] updatePeerInfo];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [[PASyncManager globalSyncManager] updateEventInfoForViewController:self];
    [[PASyncManager globalSyncManager] updateDiningInfo];

    NSLog(@"View will appear (events)");
    showingDetail = NO;
    [self registerForKeyboardNotifications];
    searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, searchBarHeight);
    self.tableView.frame = CGRectMake(0, searchBarHeight, self.view.frame.size.width, (self.view.frame.size.height) - searchBarHeight);
    initialTableViewRect= self.tableView.frame;

}

-(void)viewWillDisappear:(BOOL)animated{
    [self.view endEditing:YES];
    [self deregisterFromKeyboardNotifications];
}

-(void)viewDidDisappear:(BOOL)animated{
    if(!showingDetail){
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cacheImageForEvent:(Event*)event{
    UIImage* loadedImage = [self.imageCache objectForKey:[event.id stringValue]];
    if(!loadedImage){
        //if there is not already an image in the cache
        if(event.imageURL){
            //if the event has a photo stored on the server
            loadedImage =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:event.imageURL]]]];
            if(loadedImage){
                //one last check to make sure that the image is obtained correctly from the server
                //change image here
                
                [self.imageCache setObject:loadedImage forKey:[event.id stringValue]];
            }
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
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"did change object");
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:{
            Event* event = (Event*) anObject;
            [self cacheImageForEvent:event];
            [self.tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            //Event *tempEvent = (Event *)anObject;
            [[PASyncManager globalSyncManager] deleteEvent: ((Event*)anObject).id];
            [self.tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView cellForRowAtIndexPath:indexPath];
            break;
            
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

#pragma mark - Table View

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
    //cell.startTimeLabel.text = [self dateToString:tempDiningEvent.start_date];
    //cell.endTimeLabel.text = [self dateToString:tempDiningEvent.end_date];
    
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     //NSLog(@"cell height (height for row): %f",cellHeight);
    Event * tempEvent = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([tempEvent.type isEqualToString:@"dining"]){
        return 44;
    }
    return 88;
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
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object;
        object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }else if([[segue identifier] isEqualToString:@"showDiningDetail"]){
        
        showingDetail=YES;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
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

    cell.clipsToBounds = YES;

    UIImageView * imageView = [[UIImageView alloc] initWithFrame:cell.frame];

    NSString * imageID = [tempEvent.id stringValue];
    UIImage * cachedImage = [self.imageCache objectForKey:imageID];

    if (cachedImage) {
        imageView.image = cachedImage;
    }
    else {
        imageView.image = [UIImage imageNamed:@"image-placeholder.png"];
    }

    imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.backgroundView = imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{/*
    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i)
    {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        CGFloat cellHeight = cell.frame.size.height;
        CGFloat cellPosition = (i * cellHeight) + cellHeight / 2;
        CGFloat scrollPosition = scrollView.contentOffset.y + (self.view.frame.size.height / 2);
        CGRect frame = cell.backgroundView.frame;
        frame.origin.y = (scrollPosition - cellPosition) / 3;
        cell.backgroundView.frame = frame;
    }*/
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
        
        
        [self reloadTheView];
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
    NSMutableArray* fetchedEvents = [[NSMutableArray alloc] init];
    for(int i =0; i<[_fetchedResultsController.fetchedObjects count];i++){
        Event* tempEvent = _fetchedResultsController.fetchedObjects[i];
        [fetchedEvents addObject:tempEvent];
    }
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        for(int i =0; i<[fetchedEvents count];i++){
            Event* event = fetchedEvents[i];
            if([event.type isEqualToString:@"simple"]){
                [self cacheImageForEvent:event];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });
    });
    
    
    [self.tableView reloadData];
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
    if(CGRectEqualToRect(self.tableView.frame, initialTableViewRect)){
        NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-keyboardSize.height);
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    if(!CGRectEqualToRect(self.tableView.frame, initialTableViewRect)){
        NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height+keyboardSize.height);
    }
    
}

@end
