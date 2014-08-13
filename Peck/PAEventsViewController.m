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
#import "PADropdownViewController.h"
#import "PAEvents.h"
#import "PASyncManager.h"
#import "PAImageManager.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"
#import "PAAssetManager.h"
#import "PANestedTableViewCell.h"

#define statusBarHeight 20
#define searchBarHeight 44
#define parallaxRange 128


#define darkColor [UIColor colorWithRed:29/255.0 green:28/255.0 blue:36/255.0 alpha:1]
#define lightColor [UIColor colorWithRed:59/255.0 green:56/255.0 blue:71/255.0 alpha:1]

struct eventImage{
    const char* imageURL;
    const char* type;
    int eventID;
};

@interface PAEventsViewController ()

@property (strong, nonatomic) UITableView *leftTableView;
@property (strong, nonatomic) UITableView *centerTableView;
@property (strong, nonatomic) UITableView *rightTableView;

@property (assign, nonatomic) CGRect leftTableViewFrame;
@property (assign, nonatomic) CGRect centerTableViewFrame;
@property (assign, nonatomic) CGRect rightTableViewFrame;



@property (strong, nonatomic) NSIndexPath * selectedCellIndex;

@property (strong, nonatomic) UIImageView* helperImageView;
@end

@implementation PAEventsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

UISearchBar * searchBar;

BOOL parallaxOn;
BOOL showingSearchBar;
NSString *searchBarText;
NSDate *today;

PAAssetManager * assetManager;

- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    appdelegate.eventsViewController = self;
    
    self.animationTime = 0.2;
    
    self.helperImageView = [[UIImageView alloc] init];
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
    [self.backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.backgroundColor = [UIColor lightTextColor];

    //we must store the profile picture every time the app loads because the local image storing is not persistent
    [self storeProfilePicture];
    
    assetManager = [PAAssetManager sharedManager];

    NSLog(@"View did load (events)");
    self.placeholderImage = [[UIImageView alloc] initWithImage:[assetManager eventPlaceholder]];
    self.placeholderImage.contentMode = UIViewContentModeScaleAspectFill;
    
    if(!self.imageCache){
        self.imageCache = [[NSCache alloc] init];
    }
    self.title = @"Events";

    parallaxOn = YES;

    self.selectedDay = 0;

    if(!searchBar){
        searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
    }
    
    if (!self.leftTableView) {
        self.leftTableView = [[UITableView alloc] init];
        [self.view addSubview:self.leftTableView];
    }
    self.leftTableView.dataSource = self;
    self.leftTableView.delegate = self;
    self.leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView * leftBackView = [[UIView alloc] init];
    leftBackView.backgroundColor = darkColor;
    [self.leftTableView setBackgroundView:leftBackView];

    if (!self.centerTableView) {
        self.centerTableView = [[UITableView alloc] init];
        [self.view addSubview:self.centerTableView];
    }
    self.centerTableView.dataSource = self;
    self.centerTableView.delegate = self;
    self.centerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *centerBackView = [[UIView alloc] init];
    centerBackView.backgroundColor = darkColor;
    [self.centerTableView setBackgroundView:centerBackView];

    if (!self.rightTableView) {
        self.rightTableView = [[UITableView alloc] init];
        [self.view addSubview:self.rightTableView];
    }
    self.rightTableView.dataSource = self;
    self.rightTableView.delegate = self;
    self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *rightBackView = [[UIView alloc] init];
    rightBackView.backgroundColor = darkColor;
    [self.rightTableView setBackgroundView:rightBackView];

    [[PASyncManager globalSyncManager] updateSubscriptions];
    [[PASyncManager globalSyncManager] updatePeerInfo];

    UIImageView *shadow = [[UIImageView alloc] initWithImage:[assetManager horizontalShadow]];
    shadow.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    [self.view addSubview:shadow];

    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(transitionToRightTableView)];
    swipeLeftGesture.numberOfTouchesRequired = 1;
    swipeLeftGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:swipeLeftGesture];

    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(transitionToLeftTableView)];
    swipeRightGesture.numberOfTouchesRequired = 1;
    swipeRightGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:swipeRightGesture];
}

- (void)storeProfilePicture
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{

        NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"profile_picture_url"];
        if(url){
        
            UIImage* profilePicture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: url]]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      @"profile_picture.jpeg" ];
            NSData* data = UIImageJPEGRepresentation(profilePicture, .5);
            [data writeToFile:path atomically:YES];
            NSLog(@"path: %@", path);
            [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"profile_picture"];
        }
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[PASyncManager globalSyncManager] updateEventInfo];
    [[PASyncManager globalSyncManager] updateDiningInfo];

    NSLog(@"View will appear (events)");
    showingSearchBar = NO;

    searchBar.frame = CGRectMake(0, -searchBarHeight, self.view.frame.size.width, searchBarHeight);

    self.leftTableViewFrame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.centerTableViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.rightTableViewFrame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);

    self.leftTableView.frame = self.leftTableViewFrame;
    self.centerTableView.frame = self.centerTableViewFrame;
    self.rightTableView.frame = self.rightTableViewFrame;

    // self.centerTableView.tableHeaderView = searchBar;

    [self tableView:self.leftTableView reloadDataFrom:self.leftFetchedResultsController];
    [self tableView:self.centerTableView reloadDataFrom:self.centerFetchedResultsController];
    [self tableView:self.rightTableView reloadDataFrom:self.rightFetchedResultsController];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"view did appear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [self backButton:self];
    
    [self.view endEditing:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
                [self.imageCache setObject:loadedImage forKey:imageURL];
            }
        }
    }
}

#pragma mark - Fetched Results controller

- (NSFetchedResultsController *)constructFetchedResultsControllerForDay:(NSInteger)day
{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSString *eventString = @"Event";
    NSEntityDescription *entity = [NSEntityDescription entityForName:eventString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];


    NSMutableArray *predicateArray =[[NSMutableArray alloc] init];
    if(searchBarText){
        NSString *attributeName = @"title";
        NSString *attributeValue = searchBarText;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@", attributeName, attributeValue];
        // the [c] dismisses case sensitivity
        [predicateArray addObject:predicate];
    }


    NSDate *selectedMorning = [self getDateForDay:day];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];
    NSDate *selectedNight = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:selectedMorning options:0];

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
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)leftFetchedResultsController
{
    if (_leftFetchedResultsController == nil) {
        _leftFetchedResultsController = [self constructFetchedResultsControllerForDay:self.selectedDay - 1];
    }
    return _leftFetchedResultsController;
}

- (NSFetchedResultsController *)centerFetchedResultsController
{
    if (_centerFetchedResultsController == nil) {
        _centerFetchedResultsController = [self constructFetchedResultsControllerForDay:self.selectedDay];
    }
    return _centerFetchedResultsController;

}

- (NSFetchedResultsController *)rightFetchedResultsController
{
    if (_rightFetchedResultsController == nil) {
        _rightFetchedResultsController = [self constructFetchedResultsControllerForDay:self.selectedDay + 1];
    }
    return _rightFetchedResultsController;

}


-(NSDate *)getDateForDay:(NSInteger) day
{
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond  fromDate:[NSDate date]];
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setHour:-hours];
    [dateComponents setMinute:-minutes];
    [dateComponents setSecond:-seconds];
    [dateComponents setDay:day];
    
    NSDate *selectedDayMorning = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    return selectedDayMorning;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.leftFetchedResultsController) {
        [self.leftTableView beginUpdates];
    }
    else if (controller == self.centerFetchedResultsController) {
        [self.centerTableView beginUpdates];
    }
    else if (controller == self.rightFetchedResultsController) {
        [self.rightTableView beginUpdates];
    }
    else {
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView * tableView = nil;
    if (controller == self.leftFetchedResultsController) {
        tableView = self.leftTableView;
    }
    else if (controller == self.centerFetchedResultsController) {
        tableView = self.centerTableView;
    }
    else if (controller == self.rightFetchedResultsController) {
        tableView = self.rightTableView;
    }
    else {
    }

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView * tableView = nil;
    if (controller == self.leftFetchedResultsController) {
        tableView = self.leftTableView;
    }
    else if (controller == self.centerFetchedResultsController) {
        tableView = self.centerTableView;
    }
    else if (controller == self.rightFetchedResultsController) {
        tableView = self.rightTableView;
    }
    else {
    }

    switch (type)
    {
        case NSFetchedResultsChangeInsert:{
            Event *event = (Event*) anObject;
            
            if (event.blurredImageURL != nil) {
                [self cacheImageForEventURL:event.blurredImageURL Type:event.type AndID:event.id];
            }
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            //Event *tempEvent = (Event *)anObject;
            [[PASyncManager globalSyncManager] deleteEvent: ((Event*)anObject).id];
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView cellForRowAtIndexPath:indexPath];
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
    if (controller == self.leftFetchedResultsController) {
        [self.leftTableView endUpdates];
    }
    else if (controller == self.centerFetchedResultsController) {
        [self.centerTableView endUpdates];
    }
    else if (controller == self.rightFetchedResultsController) {
        [self.rightTableView endUpdates];
    }
    else {
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.leftTableView) {
        return [[self.leftFetchedResultsController sections] count];
    }
    else if (tableView == self.centerTableView) {
        return [[self.centerFetchedResultsController sections] count];
    }
    else if (tableView == self.rightTableView) {
        return [[self.rightFetchedResultsController sections] count];
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.leftTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.leftFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else if (tableView == self.centerTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.centerFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else if (tableView == self.rightTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.rightFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else {
        return 0;
    }

}

- (PANestedTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *fetchedResultsController = nil;
    if (tableView == self.leftTableView) {
        fetchedResultsController = self.leftFetchedResultsController;
    }
    else if (tableView == self.centerTableView) {
        fetchedResultsController = self.centerFetchedResultsController;
    }
    else if (tableView == self.rightTableView) {
        fetchedResultsController = self.rightFetchedResultsController;
    }
    else {
        return nil;
    }

    Event *eventObject = [fetchedResultsController objectAtIndexPath:indexPath];

    if ([eventObject.type isEqualToString:@"dining"]) {
        PANestedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diningCell"];
        if (cell == nil) {
            [tableView registerClass:[PANestedTableViewCell class] forCellReuseIdentifier:@"diningCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"diningCell"];
        }

        if (cell.viewController == nil) {
            cell.viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dining-places-view-controller"];
            [self addChildViewController:cell.viewController];
            [cell addSubview:cell.viewController.view];
            [cell.viewController didMoveToParentViewController:self];
        }

        cell.clipsToBounds = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.viewController.view.userInteractionEnabled = NO;
        [cell.viewController setManagedObject:eventObject];

        // [self configureDetailViewControllerCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else {
        PANestedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
        if (cell == nil) {
            [tableView registerClass:[PANestedTableViewCell class] forCellReuseIdentifier:@"eventCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
        }

        if (cell.viewController == nil) {
            cell.viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"event-info-view-controller"];

            cell.viewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self addChildViewController:cell.viewController];
            [cell addSubview:cell.viewController.view];
            [cell.viewController didMoveToParentViewController:self];
        }

        cell.clipsToBounds = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.viewController.view.userInteractionEnabled = NO;
        [cell.viewController setManagedObject:eventObject];

        // [self configureDetailViewControllerCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}


/*

- (void)configureEventCell:(PAEventCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[PAEventCell class]]){
        Event *tempEvent;

        tempEvent = [self.centerFetchedResultsController objectAtIndexPath:indexPath];

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

-(void)configureDiningCell:(PADiningOpportunityCell*)cell atIndexPath:(NSIndexPath*)indexPath
{

    Event* tempDiningEvent = [self.centerFetchedResultsController objectAtIndexPath:indexPath];

    cell.nameLabel.text = tempDiningEvent.title;
    //cell.startTimeLabel.text = [self dateToString:tempDiningEvent.start_date];
    //cell.endTimeLabel.text = [self dateToString:tempDiningEvent.end_date];
    
}

*/

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController * fetchedResultsController = nil;
    if (tableView == self.leftTableView) {
        fetchedResultsController = self.leftFetchedResultsController;
    }
    else if (tableView == self.centerTableView) {
        fetchedResultsController = self.centerFetchedResultsController;
    }
    else if (tableView == self.rightTableView) {
        fetchedResultsController = self.rightFetchedResultsController;
    }
    else {
        return 0;
    }

    Event * tempEvent = [fetchedResultsController objectAtIndexPath:indexPath];

    if ([self indexPathIsSelected:indexPath]) {
        return self.view.frame.size.height;
    }
    else if([tempEvent.type isEqualToString:@"dining"]){
        return 44;
    }
    return 88;
}

- (void)backButton:(id)sender
{
    PANestedTableViewCell *cell = (PANestedTableViewCell *)[self.centerTableView cellForRowAtIndexPath:self.selectedCellIndex];
    cell.viewController.view.userInteractionEnabled = NO;
    [cell.viewController compressAnimated:YES];
    [self tableView:self.centerTableView compressRowAtSelectedIndexPathUserInteractionEnabled:NO];
    self.selectedCellIndex = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self indexPathIsSelected:indexPath]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    Event *selectedEvent = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([selectedEvent.type isEqualToString:@"simple"]){
        [self performSegueWithIdentifier:@"showEventDetail" sender:self];
    }
    else if([selectedEvent.type isEqualToString:@"dining"]){
        [self performSegueWithIdentifier:@"showDiningDetail" sender:self];
    }
     */

    /*
     NSLog(@"selected cell %ld", (long)indexPath.row);

     UIViewController * newVC = self.detailViewControllers[indexPath.row];
     [newVC.view addSubview:self.backButton];

     newVC.view.userInteractionEnabled = YES;

     self.selectedCellIndexPath = indexPath;
     [self.tableView beginUpdates];
     [self.tableView endUpdates];
     [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
     self.tableView.scrollEnabled = NO;
     */

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedCellIndex = indexPath;
    PANestedTableViewCell *cell = (PANestedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.viewController.view.userInteractionEnabled = YES;
    [cell.viewController expandAnimated:YES];
    [self tableView:tableView expandRowAtIndexPath:indexPath];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.centerFetchedResultsController managedObjectContext];
        [context deleteObject:[self.centerFetchedResultsController objectAtIndexPath:indexPath]];
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

/*
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*

   for (NSInteger i = 0; i < [self.centerTableView numberOfRowsInSection:0]; ++i)
    {
        if (parallaxOn) {
            // Check if cell is a PAEventCell, which has a backgroundView.image property
            UITableViewCell * c = [self.centerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
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
     */
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [searchBar resignFirstResponder];
}

#pragma mark - Search Bar Delegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Text did change");
    if([searchText isEqualToString:@""]){
        searchBar.text = nil;
        searchBarText = nil;
        //[self tableView:self.centerTableView reloadDataFrom:self.centerFetchedResultsController];
        NSLog(@"User cancelled search");
    }
    else{
        searchBarText = searchText;
        //[self tableView:self.centerTableView reloadDataFrom:self.centerFetchedResultsController];
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
    //self.centerFetchedResultsController = nil;
    //[self tableView:self.centerTableView reloadDataFrom:self.centerFetchedResultsController];
    NSLog(@"User cancelled search");
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}

#pragma mark - View management

/*
- (IBAction)yesterdayButton:(id)sender {
    NSLog(@"Yesterday");
    self.selectedDay--;
    //self.centerFetchedResultsController = nil;
    [self reloadTheView];
}

- (IBAction)todayButton:(id)sender {
    self.selectedDay = 0;
    //self.centerFetchedResultsController = nil;
    NSLog(@"Today");
    [self reloadTheView];
}

- (IBAction)tomorrowButton:(id)sender {
    self.selectedDay++;
    //self.centerFetchedResultsController = nil;
    NSLog(@"Tomorrow");
    [self reloadTheView];
}
*/

- (void)transitionToRightTableView
{
    if (self.selectedCellIndex == nil) {
    NSLog(@"begin transition to right");
    [UIView animateWithDuration:self.animationTime delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.rightTableView.frame = self.centerTableViewFrame;
                         self.centerTableView.frame = self.leftTableViewFrame;
                     }
                     completion:^(BOOL finished){
                         self.leftTableView.frame = self.rightTableViewFrame;

                         UITableView * tempView = self.leftTableView;
                         self.leftTableView = self.centerTableView;
                         self.centerTableView = self.rightTableView;
                         self.rightTableView = tempView;

                         self.selectedDay += 1;

                         self.leftFetchedResultsController = self.centerFetchedResultsController;
                         self.centerFetchedResultsController = self.rightFetchedResultsController;
                         self.rightFetchedResultsController = nil;

                         [self tableView:self.rightTableView reloadDataFrom:self.rightFetchedResultsController];

                         NSLog(@"end transition to right");
                     }];
    }
}

-(void)transitionToLeftTableView
{
    if (self.selectedCellIndex == nil) {
    NSLog(@"begin transition to left");
    [UIView animateWithDuration:self.animationTime delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.leftTableView.frame = self.centerTableViewFrame;
                         self.centerTableView.frame = self.rightTableViewFrame;
                     }
                     completion:^(BOOL finished){
                         self.rightTableView.frame = self.leftTableViewFrame;

                         self.selectedDay -= 1;

                         self.rightFetchedResultsController = self.centerFetchedResultsController;
                         self.centerFetchedResultsController = self.leftFetchedResultsController;
                         self.leftFetchedResultsController = nil;

                         UITableView * tempView = self.rightTableView;
                         self.rightTableView = self.centerTableView;
                         self.centerTableView = self.leftTableView;
                         self.leftTableView = tempView;

                         [self tableView:self.leftTableView reloadDataFrom:self.leftFetchedResultsController];

                         NSLog(@"end transition to left");
                     }];
    }
}

- (void)tableView:(UITableView *)tableView reloadDataFrom:(NSFetchedResultsController *)fetchedResultsController
{
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error])
    {
        NSLog(@"Fetched results controller could not perform fetch");
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }


    for(Event* event in fetchedResultsController.fetchedObjects){
        if (event.imageURL) {
            [self cacheImageForURL:event.imageURL];
        }
        if (event.blurredImageURL) {
            [self cacheImageForURL:event.blurredImageURL];
        }
    }

    /*
    NSMutableArray* eventURLs = [[NSMutableArray alloc] init];
    NSMutableArray* eventTypes = [[NSMutableArray alloc] init];
    NSMutableArray* eventIDs = [[NSMutableArray alloc] init];
    NSMutableArray* eventRows = [[NSMutableArray alloc] init];
    for(int i = 0; i < [fetchedResultsController.fetchedObjects count]; i++){
        
        Event* tempEvent = fetchedResultsController.fetchedObjects[i];
        
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
     */

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

    /*
    for(int i = 0; i<[eventIDs count]; i++){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            [self cacheImageForEventURL:eventURLs[i] Type:eventTypes[i] AndID:eventIDs[i]];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath* indexPath =[NSIndexPath indexPathForRow: [eventRows[i] integerValue] inSection:0];
                /
                PAEventCell* cell = (PAEventCell*)[tableView cellForRowAtIndexPath:indexPath];
                if(fetchedResultsController.fetchedObjects.count > indexPath.row){
                    if ([cell isKindOfClass:[PAEventCell class]]) {
                        // [self configureEventCell:cell atIndexPath:indexPath];
                    }
                }
                //to reload the cell after the image is cached
            });
        });
    }
     */

    [tableView reloadData];
    [tableView beginUpdates];
    [tableView endUpdates];
}

-(void)cacheImageForURL:(NSString*)urlString{
    NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:urlString]];
    //self.helperImageView.image=nil;
    self.helperImageView.image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
    if(!self.helperImageView.image){
        //we must use an image view to cache the image, even if we never display this image view
        [self.helperImageView setImageWithURL:imageURL];
    }
}

#pragma mark - keyboard notifications

/*
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
    if (CGRectEqualToRect(self.centerTableView.frame, self.centerTableViewFrame)){
        NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.centerTableView.frame = CGRectMake(self.centerTableView.frame.origin.x, self.centerTableView.frame.origin.y, self.centerTableView.frame.size.width, self.centerTableView.frame.size.height-keyboardSize.height);
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    if(!CGRectEqualToRect(self.centerTableView.frame, self.centerTableViewFrame)){
        NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.centerTableView.frame = CGRectMake(self.centerTableView.frame.origin.x, self.centerTableView.frame.origin.y, self.centerTableView.frame.size.width, self.centerTableView.frame.size.height+keyboardSize.height);
    }
}
 */

@end

