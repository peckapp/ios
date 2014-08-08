//
//  PAPecksViewController.m
//  Peck
//
//  Created by Jonas Luebbers on 6/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//



#import "PAPecksViewController.h"
#import "PAAppDelegate.h"
#import "Peck.h"
#import "PAPeckCell.h"
#import "PASyncManager.h"
#import "PAPromptView.h"
#import "PAAssetManager.h"

@interface PAPecksViewController ()
@property BOOL editing;
@property (strong) PAPromptView* promptView;
@end

@implementation PAPecksViewController

static NSString *cellIdentifier = PAPecksIdentifier;
static NSString *nibName = @"PAPeckCell";

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
    
    if(!self.noPecksLabel){
        self.noPecksLabel = [[UILabel alloc] init];
    }
    
    NSError *error=nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
   /* _fetchedResultsController=nil;
    NSError *error=nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }*/

    if([[NSUserDefaults standardUserDefaults] objectForKey:@"authentication_token"]){
      
        [[PASyncManager globalSyncManager] updatePecks];
        
        if([_fetchedResultsController.fetchedObjects count]==0){
            [self showNoPecks];
        }
        else{
            [self showPecks];
        }
    
        
    }else{
        self.tableView.backgroundColor = [[PAAssetManager sharedManager] unavailableColor];
        self.tableView.separatorColor = [[PAAssetManager sharedManager] unavailableColor];
        
        _promptView = [PAPromptView promptView:self];
        
        [self.view addSubview:_promptView];
        
    }
}
-(void)showNoPecks{
    self.tableView.backgroundColor = [[PAAssetManager sharedManager] unavailableColor];
    self.tableView.separatorColor = [[PAAssetManager sharedManager] unavailableColor];
    self.noPecksLabel.text = @"You have no Pecks";
    self.noPecksLabel.textColor = [UIColor whiteColor];
    self.noPecksLabel.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    self.noPecksLabel.textAlignment = NSTextAlignmentCenter;
    self.noPecksLabel.font = [UIFont systemFontOfSize:28];
    
    [self.view addSubview:self.noPecksLabel];

}

-(void)showPecks{
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor lightGrayColor];
    [self.noPecksLabel removeFromSuperview];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_promptView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PAPeckCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // Configure cell by loading a nib.
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    self.editing=YES;
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    self.editing=NO;
}

-(void)configureCell:(PAPeckCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Peck* peck = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.messageTextView.text = peck.message;
    cell.titleLabel.text = @"Peck";
    if([peck.notification_type isEqualToString:@"circle_invite"] || [peck.notification_type isEqualToString:@"event_invite"]){
        cell.invitation_id = [peck.invitation_id integerValue];
        cell.invitation_id = [peck.invitation_id integerValue];
        cell.notification_type = peck.notification_type;
        cell.invited_by = peck.invited_by;
    }
    [cell.acceptButton setHidden:NO];
    [cell.declineButton setHidden:NO];
    if([peck.notification_type isEqualToString:@"circle_comment"]){
        [cell.acceptButton setHidden:YES];
        [cell.declineButton setHidden:YES];
    }
    [cell.acceptButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cell.declineButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    cell.interactedWith = NO;
    if([peck.interacted_with boolValue]==YES){
        [cell.acceptButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [cell.declineButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        cell.interactedWith = YES;
    }
    cell.dateLabel.text = [self dateToString:peck.created_at];
    cell.peckID = peck.id;
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
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Peck* peck = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([peck.notification_type isEqualToString:@"event_invite"]){
        NSLog(@"show the detail of the event");
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - managing the fetched results controller

-(NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController!=nil){
        return _fetchedResultsController;
    }
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSString * eventString = @"Peck";
    NSEntityDescription *entity = [NSEntityDescription entityForName:eventString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
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
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            if([_fetchedResultsController.fetchedObjects count]>0){
                [self showPecks];
            }
            //this line is here because the table view would usually set the second cell to have the same properties as the cell that was just inserted
            [self.tableView reloadData];
            break;
        }
        case NSFetchedResultsChangeDelete:{
            if(self.editing){
                //only delete the peck from the server if the user is editing the table view rather than deleting the pecks from core data somewhere else (i.e. when he logs out)
                [[PASyncManager globalSyncManager] deletePeck: ((Peck*)anObject).id];
            }
            [self.tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            if([_fetchedResultsController.fetchedObjects count]==0){
                [self showNoPecks];
            }
            break;
        }
        case NSFetchedResultsChangeUpdate:{
            PAPeckCell* cell = (PAPeckCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            break;
        }
            
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


- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
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
/*
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[PASyncManager globalSyncManager] deletePeck: [_fetchedResultsController objectAtIndexPath:indexPath] ];
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
