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

@interface PADiningPlacesTableViewController ()
@property NSArray* diningPlaces;

@end

@implementation PADiningPlacesTableViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
    [self reloadDiningPeriods];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        
        self.title = [self.detailItem valueForKey:@"title"];
        
        NSSet *dining = [self.detailItem valueForKey:@"dining_place"];
        self.diningPlaces = [dining allObjects];
        
        for(int i=0; i<[self.diningPlaces count];i++){
            DiningPlace *tempDiningPlace = self.diningPlaces[i];
            [[PASyncManager globalSyncManager] getDiningPeriodForPlace:tempDiningPlace andOpportunity:self.detailItem withViewController:self forNumberAdded:i];
        }
        [self.tableView reloadData];
    }
}
-(void)reloadDiningPeriods{
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
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PADiningCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diningCell"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PADiningCell" bundle:nil] forCellReuseIdentifier:@"diningCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"diningCell"];
    }

    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(PADiningCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    cell=(PADiningCell*)cell;
    DiningPlace *tempDiningPlace = self.diningPlaces[indexPath.row];
    
    DiningPeriod *tempDiningPeriod = [self diningPeriodFromPlace:tempDiningPlace];
    if(tempDiningPeriod){
        cell.startLabel.text = [self dateToString:tempDiningPeriod.start_date];
        cell.endLabel.text = [self dateToString:tempDiningPeriod.end_date];
    }
    [cell.nameLabel setText:tempDiningPlace.name];
    
}
-(DiningPeriod*)diningPeriodFromPlace:(DiningPlace*)diningPlace {
    NSSet*dining = diningPlace.dining_period;
    NSArray*diningPeriods = [dining allObjects];
    for(int i=0;i<[diningPeriods count];i++){
        DiningPeriod *tempDiningPeriod = diningPeriods[i];
        if(tempDiningPeriod.day_of_week==[NSNumber numberWithInt:0] && tempDiningPeriod.place_id==diningPlace.id &&tempDiningPeriod.opportunity_id==[self.detailItem valueForKey:@"id"]){
            return tempDiningPeriod;
        }
    }
    return nil;
    
    
    
}

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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
