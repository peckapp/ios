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
#import "UIImageView+AFNetworking.h"
#import "PAAssetManager.h"

#define statusBarHeight 20
#define searchBarHeight 44
#define parallaxRange 128

#define darkColor [UIColor colorWithRed:29/255.0 green:28/255.0 blue:36/255.0 alpha:1]
#define lightColor [UIColor colorWithRed:59/255.0 green:56/255.0 blue:71/255.0 alpha:1]

struct eventImage{
    const char* imageURL;
    const char* type ;
    int eventID;
};

@interface PAEventsViewController ()

@end

@implementation PAEventsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * cellIdentifier = PAPrimaryIdentifier;
static NSString * nibName = @"PAEventCell";

UISearchBar * searchBar;

BOOL parallaxOn;
BOOL showingDetail;
BOOL showingSearchBar;
NSString *searchBarText;
NSDate *today;
NSInteger selectedDay;
CGRect initialTableViewRect;

PAAssetManager * assetManager;

- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    assetManager = [PAAssetManager sharedManager];

    NSLog(@"View did load (events)");
    self.placeholderImage = [[UIImageView alloc] initWithImage:[assetManager eventPlaceholder]];
    self.placeholderImage.contentMode = UIViewContentModeScaleAspectFill;
    
    if(!self.imageCache){
        self.imageCache = [[NSCache alloc] init];
    }
    self.title = @"Events";

    // TODO: optimize parallax? Currently takes a couple percent cpu extra and a two megabytes
    parallaxOn = YES;

    selectedDay=0;
    showingDetail = NO;
    [self reloadTheView];
    if(!searchBar){
        searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
    }
    
    
   
    
    if(!self.tableView){
        self.tableView = [[UITableView alloc] init];
        [self.view addSubview:self.tableView];
    }

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    UIView * backView = [[UIView alloc] init];
    backView.backgroundColor = darkColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = lightColor;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView setBackgroundView:backView];

    [[PASyncManager globalSyncManager] updateSubscriptions];
    [[PASyncManager globalSyncManager] updatePeerInfo];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView reloadData];

    UIImageView * shadow = [[UIImageView alloc] initWithImage:[assetManager horizontalShadow]];
    shadow.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    NSLog(@"Added shadow");
    [self.view addSubview:shadow];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [[PASyncManager globalSyncManager] updateEventInfo];
    [[PASyncManager globalSyncManager] updateDiningInfo];

    NSLog(@"View will appear (events)");
    showingSearchBar = NO;
    showingDetail = NO;
    [self registerForKeyboardNotifications];
    searchBar.frame = CGRectMake(0, -searchBarHeight, self.view.frame.size.width, searchBarHeight);
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height));
    initialTableViewRect= self.tableView.frame;

    self.tableView.tableHeaderView = searchBar;
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
    
    
    NSLog(@"Clearing imageCache due to memory warning");
    [self.imageCache removeAllObjects];
}

- (void)cacheImageForEventURL:(NSString*)imageURL Type: (NSString*)type AndID: (NSNumber*)eventID {
    UIImage* loadedImage = [self.imageCache objectForKey:[eventID stringValue]];
    if(!loadedImage){
        //if there is not already an image in the cache
        if(imageURL){
            //if the event has a photo stored on the server
            NSLog(@"caching image for event %@", [eventID stringValue]);
            NSURL * url = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:imageURL]];
            
            
            loadedImage =[UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if(loadedImage){

                //UIImage * blurredImage = [loadedImage applyDarkEffect];
                //UIImageView * imageView = [[UIImageView alloc] initWithImage:blurredImage];
                //imageView.contentMode = UIViewContentModeScaleAspectFill;
                [self.imageCache setObject:loadedImage forKey:[eventID stringValue]];
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
            
            if (event.blurredImageURL != nil) {
                
                [self cacheImageForEventURL:event.blurredImageURL Type:event.type AndID:event.id];
                
            }
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    [self configureEventCell:cell atIndexPath:indexPath];
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
    }
    else if ([[segue identifier] isEqualToString:@"showDiningDetail"]) {
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


- (void)configureEventCell:(PAEventCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[PAEventCell class]]){
    Event *tempEvent;
    
    tempEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = tempEvent.title;
    cell.startTime.text = [self dateToString:tempEvent.start_date];
    cell.endTime.text = [self dateToString:tempEvent.end_date];

    cell.clipsToBounds = YES;

    NSString * imageID = [tempEvent.id stringValue];
    
    NSLog(@"event %@ has an imageID of %@",tempEvent.title, imageID);
    
    
    UIImage * cachedImage = [self.imageCache objectForKey:imageID];
    //NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:tempEvent.imageURL]];
    //UIImage* cachedImage = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];

    //cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (cachedImage) {
        cell.eventImageView.image = cachedImage;
    }
    else {
        cell.eventImageView.image = self.placeholderImage.image;
    }

    //cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

   for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i)
    {
        if (parallaxOn) {
            // Check if cell is a PAEventCell, which has a backgroundView.image property
            UITableViewCell * c = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([c isKindOfClass:[PAEventCell class]]) {
                PAEventCell * cell = (PAEventCell *)c;

                // Get Height of current image
                // UIImage * image = cell.backgroundView.image;
                // CGFloat imageHeight = image.size.height * (cell.frame.size.width / image.size.width);

                CGFloat imageHeight = parallaxRange;
                CGFloat cellHeight = cell.frame.size.height;
                CGFloat cellY = i * cellHeight;
                CGFloat scrollY = scrollView.contentOffset.y - searchBarHeight;
                CGFloat topY = imageHeight / 2 - cellHeight / 2;
                CGFloat bottomY = cellHeight / 2 - imageHeight / 2;

                CGRect frame = cell.eventImageView.frame;
                frame.origin.y = topY + ((cellY - scrollY) / (scrollView.frame.size.height - cellHeight)) * (bottomY - topY);
                
                
                cell.eventImageView.frame = frame;
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [searchBar resignFirstResponder];
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
    NSMutableArray* eventURLs = [[NSMutableArray alloc] init];
    NSMutableArray* eventTypes = [[NSMutableArray alloc] init];
    NSMutableArray* eventIDs = [[NSMutableArray alloc] init];
    NSMutableArray* eventRows = [[NSMutableArray alloc] init];
    for(int i =0; i<[_fetchedResultsController.fetchedObjects count];i++){
        
        Event* tempEvent = _fetchedResultsController.fetchedObjects[i];
        
        // cannot asynchronously cache image it there isn't one
        if (tempEvent.blurredImageURL != nil && ![tempEvent.blurredImageURL isEqualToString:@"/images/missing.png"]) {
            if(![self.imageCache objectForKey:[tempEvent.id stringValue]]){
                //if the image is not already cached
                [eventURLs addObject:tempEvent.blurredImageURL];
                [eventTypes addObject:tempEvent.type];
                [eventIDs addObject:tempEvent.id];
                [eventRows addObject:[NSNumber numberWithInt:i]];
            }
        }
        
    }
    /*
    for(int j=0; j<[eventIDs count];j++){
        if( [eventTypes[j] isEqualToString:@"simple"]){
            NSURL * url = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:eventURLs[j]]];
            UIImage* cachedImage = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:url]];
            if(!cachedImage){
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[eventRows[j] integerValue] inSection:0];
                PAEventCell* cell = (PAEventCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                if(![cell isKindOfClass:[PADiningOpportunityCell class]]){
                    [cell.eventImageView setImageWithURL:url placeholderImage:self.placeholderImage.image];
                }
            }
        }
    }
    */
   
    for(int i =0; i<[eventIDs count];i++){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            [self cacheImageForEventURL:eventURLs[i] Type:eventTypes[i] AndID:eventIDs[i]];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath* indexPath =[NSIndexPath indexPathForRow: [eventRows[i] integerValue] inSection:0];
                PAEventCell* cell = (PAEventCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                if(_fetchedResultsController.fetchedObjects.count > indexPath.row){
                    if ([cell isKindOfClass:[PAEventCell class]]) {
                        [self configureEventCell:cell atIndexPath:indexPath];
                    }
                }
                //to reload the cell after the image is cached
            });
        });
    }
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

/*

@interface EventInfo : NSObject {}

@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, assign, nonatomic) NSUInteger time;

@end

@implementation EventInfo : NSObject 

@synthesize name;
@synthesize time;

@end
 
*/

