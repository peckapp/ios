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

@interface PADiningPlacesTableViewController ()
@property NSMutableArray* diningPlaces;
@property NSIndexPath* selectedIndexPath;

@end

@implementation PADiningPlacesTableViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#define cellHeight 120

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
    self.selectedIndexPath=nil;
    self.diningPlaces = [[NSMutableArray alloc] init];
    //self.tableView.rowHeight=120;
    [self configureView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.tableView.backgroundColor = [[PAAssetManager sharedManager] darkColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)expandAnimated:(BOOL)animated
{

}

- (void)compressAnimated:(BOOL)animated
{

}

#pragma mark - managing the detail item

- (void)setDetailItem:(id)newDetailItem
{

}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        
        self.title = [self.detailItem valueForKey:@"title"];
        
        [self fetchDiningPeriods];
        [self.tableView reloadData];
    }
}

- (void)setManagedObject:(NSManagedObject *)managedObject
{
    if (_detailItem != managedObject) {
        _detailItem = managedObject;

        self.mealLabel.text = [self.detailItem valueForKey:@"title"];
        [self fetchDiningPeriods];
        [self.tableView reloadData];
    }
}

- (void)fetchDiningPeriods{
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiningPeriod" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"opportunity_id";
    NSNumber *attributeValue = [self.detailItem valueForKey:@"id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSWeekdayCalendarUnit) fromDate:[NSDate date]];
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
    if((self.selectedIndexPath != nil) && (indexPath.row == self.selectedIndexPath.row)) {
        return self.view.frame.size.height;
    }
    return cellHeight;
}



#pragma mark - table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectedIndexPath==nil){
        DiningPlace *tempDiningPlace = self.diningPlaces[indexPath.row];
        PADiningCell *cell = (PADiningCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.diningOpportunity=self.detailItem;
        cell.diningPlace=tempDiningPlace;
        [cell performFetch];
        [[PASyncManager globalSyncManager] updateMenuItemsForOpportunity:self.detailItem andPlace:tempDiningPlace];
        self.selectedIndexPath = indexPath;
        [tableView beginUpdates];
        [tableView endUpdates];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [tableView setScrollEnabled:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [tableView setScrollEnabled:YES];
        self.selectedIndexPath=nil;
        [tableView beginUpdates];
        [tableView endUpdates];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
    
    cell.startLabel.text = [self dateToString:tempDiningPlace.start_date];
    cell.endLabel.text = [self dateToString:tempDiningPlace.end_date];
    [cell.nameLabel setText:tempDiningPlace.name];
    
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
