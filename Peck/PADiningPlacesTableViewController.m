//
//  PADiningPlacesTableViewController.m
//  Peck
//
//  Created by John Karabinos on 7/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PADiningPlacesTableViewController.h"
#import "PAAppDelegate.h"
#import "DiningPlace.h"
#import "Event.h"
#import "PASyncManager.h"
#import "DiningPeriod.h"
#import "PADiningCell.h"
#import "PAAssetManager.h"
#import "PANestedTableViewCell.h"
#import "PADiningOpportunityViewController.h"

#import <QuartzCore/QuartzCore.h>

#define cellHeight 88

#define BACK_BTN_SIZE 64
#define separatorWidth 1.0

@interface PADiningPlacesTableViewController ()

@property (strong, nonatomic) NSMutableArray *diningPlaces;

@property (strong, nonatomic) UIView *parentBackButtonView;

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *periodLabel;

// default separators to deliniate cell divisions. to be turned off for cells that display pictures
@property (strong, nonatomic) CALayer *upperSeparator;
@property (strong, nonatomic) CALayer *lowerSeparator;

-(void) showSeparators;
-(void) hideSeparators;

@end


@implementation PADiningPlacesTableViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

PAAssetManager *assetManager;

- (void)viewDidLoad
{
    [super viewDidLoad];

    assetManager = [PAAssetManager sharedManager];

    self.view.backgroundColor = [assetManager darkColor];

    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - BACK_BTN_SIZE, 0, BACK_BTN_SIZE, BACK_BTN_SIZE)];
    [self.backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton addSubview:[assetManager createPanelWithFrame:CGRectInset(self.backButton.bounds, 15, 15) rounded:YES shadow:YES]];
    UIImageView *cancelIcon = [[UIImageView alloc] initWithImage:[assetManager cancelIcon]];
    cancelIcon.frame = self.backButton.bounds;
    cancelIcon.contentMode = UIViewContentModeScaleAspectFit;
    cancelIcon.userInteractionEnabled = NO;
    [self.backButton addSubview:cancelIcon];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [assetManager darkColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [assetManager lightColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];

    self.headerView = [[UIView alloc] init];

    self.periodLabel = [[UILabel alloc] init];
    self.periodLabel.textColor = [UIColor whiteColor];
    self.periodLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.headerView addSubview:self.periodLabel];

    //self.diningPlaces = [[NSMutableArray alloc] init];
    self.diningPlaces = nil;

    self.parentBackButtonView = [[UIView alloc] init];
    [self.view addSubview:self.parentBackButtonView];
    
    
    self.upperSeparator = [[CALayer alloc] init];
    [self.upperSeparator setBackgroundColor:[[[PAAssetManager sharedManager] lightColor] CGColor]];
    self.lowerSeparator = [[CALayer alloc] init];
    [self.lowerSeparator setBackgroundColor:[[[PAAssetManager sharedManager] lightColor] CGColor]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.frame = self.parentViewController.view.bounds;

    self.tableView.frame = self.view.frame;

    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    self.tableView.tableHeaderView = self.headerView;
    
    self.periodLabel.frame = CGRectInset(self.headerView.frame, 15, 0);
    
    [self showSeparators];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self backButton:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)expandAnimated:(BOOL)animated
{
    self.diningPlaces = [[NSMutableArray alloc] init];
    [self fetchDiningPeriods];
    [self.tableView reloadData];
    self.view.frame = self.parentViewController.view.bounds;
    self.viewFrame = self.parentViewController.view.bounds;
    //NSLog(@"dining places view frame %@", NSStringFromCGRect(self.view.bounds));
    
    [self hideSeparators];
}

- (void)compressAnimated:(BOOL)animated
{
    self.diningPlaces=nil;
    [self.tableView reloadData];
    
    [self showSeparators];
}

- (UIView *)viewForBackButton
{
    self.parentBackButtonView.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    return self.parentBackButtonView;
}

#pragma mark - managing the detail item

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        
        self.periodLabel.text = [self.detailItem valueForKey:@"title"];
        
        
    }
}

-(void) showSeparators {
    [self.view.layer addSublayer:self.upperSeparator];
    self.upperSeparator.frame = CGRectMake(self.view.layer.frame.origin.x, self.view.layer.frame.origin.y, self.view.layer.frame.size.width, separatorWidth);
    
    [self.view.layer addSublayer:self.lowerSeparator];
    self.lowerSeparator.frame = CGRectMake(self.view.layer.frame.origin.x, self.containingCell.layer.frame.size.height - separatorWidth, self.view.layer.frame.size.width, separatorWidth);
}

-(void) hideSeparators {
    [self.upperSeparator removeFromSuperlayer];
    
    [self.lowerSeparator removeFromSuperlayer];
}

- (void)setManagedObject:(NSManagedObject *)managedObject parentObject:(NSManagedObject *)parentObject
{
    if (_detailItem != managedObject) {
        _detailItem = managedObject;

        [self configureView];
    }
}

- (void)fetchDiningPeriods{
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiningPeriod" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"opportunity_id";
    NSNumber *attributeValue = [self.detailItem valueForKey:@"opportunity_id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitWeekday) fromDate:[NSDate date]];
    NSNumber * day = [NSNumber numberWithLong:([components weekday]-1)];
    
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"day_of_week = %@", day];
    NSArray* predicateArray = [[NSArray alloc] initWithObjects:predicate, dayPredicate, nil];
    NSPredicate *compoundPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [fetchRequest setPredicate:compoundPredicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if([mutableFetchResults count]>0){
        
        for(int i=0; i<[mutableFetchResults count];i++){
            DiningPeriod *tempDiningPeriod = mutableFetchResults[i];
            [self fetchDiningPlace:tempDiningPeriod];
        }
    }
    else{
        [[PASyncManager globalSyncManager] updateDiningPeriods:self.detailItem forViewController:self];
    }
}

-(void)fetchDiningPlace:(DiningPeriod*)diningPeriod{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiningPlace" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"id";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",attributeName, diningPeriod.place_id];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if([mutableFetchResults count]>0){
        DiningPlace *tempDiningPlace = mutableFetchResults[0];
        tempDiningPlace.start_date = diningPeriod.start_date;
        tempDiningPlace.end_date = diningPeriod.end_date;
        [self.diningPlaces addObject:tempDiningPlace];
        [self.tableView reloadData];
    }
    else{
        [[PASyncManager globalSyncManager] updateDiningPlaces:diningPeriod forController:self];
    }
}

-(void)addDiningPlace:(DiningPlace*) diningPlace withPeriod:(DiningPeriod*)diningPeriod{
    diningPlace.start_date = diningPeriod.start_date;
    diningPlace.end_date = diningPeriod.end_date;
    [self.diningPlaces addObject:diningPlace];
    
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.diningPlaces count];
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self indexPathIsSelected:indexPath]) {
        return self.view.frame.size.height;
    }
    else {
        return cellHeight;
    }
}



#pragma mark - table view delegate


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PANestedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dining-opportunity-cell-identifier"];
    if (cell == nil) {
        [tableView registerClass:[PANestedTableViewCell class] forCellReuseIdentifier:@"dining-opportunity-cell-identifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"dining-opportunity-cell-identifier"];
    }

    if (cell.viewController == nil) {
        cell.viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dining-opportunity-view-controller"];
        cell.viewController.view.frame = self.view.bounds;
        [self addChildViewController:cell.viewController];
        [cell addSubview:cell.viewController.view];
        [cell.viewController didMoveToParentViewController:self];
    }

    cell.clipsToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.viewController.view.userInteractionEnabled = NO;
    DiningPlace* diningPlace = self.diningPlaces[indexPath.row];
    //NSLog(@"dining place id in configure cell: %@", diningPlace.id);
    [cell.viewController setManagedObject:diningPlace parentObject:self.detailItem];

    return cell;
}

- (void)backButton:(id)sender
{
    PANestedTableViewCell *cell = (PANestedTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedCellIndexPath];
    cell.viewController.view.userInteractionEnabled = NO;
    [cell.viewController compressAnimated:YES];
    [self tableView:self.tableView compressRowAtSelectedIndexPathAnimated:YES];

    self.parentBackButtonView.hidden = NO;
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

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedCellIndexPath = indexPath;
    PANestedTableViewCell *cell = (PANestedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.viewController.view.userInteractionEnabled = YES;
    PADiningOpportunityViewController* viewController =  (PADiningOpportunityViewController*)cell.viewController;
    viewController.parentController = self;
    [cell.viewController expandAnimated:YES];
    [[cell.viewController viewForBackButton] addSubview:self.backButton];

    self.parentBackButtonView.hidden = YES;

    [self tableView:tableView expandRowAtIndexPath:indexPath animated:YES];
}

-(NSString*)dateToString:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
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


@end
