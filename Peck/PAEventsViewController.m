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

@interface PAEventsViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end

@implementation PAEventsViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSCache *imageCache;

- (void)awakeFromNib
{
    [super awakeFromNib];
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if(!imageCache){
        imageCache = [[NSCache alloc] init];
    }
       
    self.title = @"Events";

    UIBarButtonItem *pecksButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showPecks:)];
    self.navigationItem.leftBarButtonItem = pecksButton;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self checkServerData];
    [self.tableView reloadData];
    }

-(void)checkServerData{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    
    
    [[PASessionManager sharedClient] GET:@"api/events"
                              parameters:nil
                                 success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"JSON: %@",JSON);
         NSArray *postsFromResponse = (NSArray*)JSON;
         NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
         for (NSDictionary *eventAttributes in postsFromResponse) {
             NSString *newID = [[eventAttributes objectForKey:@"id"] stringValue];
             BOOL eventAlreadyExists = [self eventExists:newID];
             if(!eventAlreadyExists){
                 NSLog(@"about to add the event");
                 Event * event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
                 [self setAttributesInEvent:event withDictionary:eventAttributes];
                 [mutableEvents addObject:event];
                 NSLog(@"EVENT: %@",event);
             }
         }
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];
    
    /*
     [[PASessionManager sharedClient] POST:@"api/events"
     parameters:@{}
     success:^(NSURLSessionDataTask *task,id responseObject) {
     NSLog(@"POST success: %@",responseObject);
     }
     failure:^(NSURLSessionDataTask *task, NSError * error) {
     NSLog(@"POST error: %@",error);
     }];
     */
}

-(BOOL)eventExists:(NSString *) newID{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *events = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    [request setEntity:events];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", newID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    //fetch events in order to check if the events we want to add already exist in core data
    
    if([mutableFetchResults count]==0)
        return NO;
    else {
        return YES;
    }
}


-(void)setAttributesInEvent:(Event *)event withDictionary:(NSDictionary *)dictionary
{
    NSLog(@"set attributes of event");
    event.title = [dictionary objectForKey:@"title"];
    event.descrip = [dictionary objectForKey:@"description"];
    event.location = [dictionary objectForKey:@"institution"];
    NSString *tempString = [[dictionary objectForKey:@"id"] stringValue];
    event.id = tempString;
    //event.isPublic = [[dictionary objectForKey:@"public"] boolValue];
    //NSDateFormatter * df = [[NSDateFormatter alloc] init];
    //event.startDate = [df dateFromString:[attributes valueForKey:@"start_date"]];
    //event.endDate = [df dateFromString:[attributes valueForKey:@"end_date"]];
    
    // the below doesn't work due to current disparity between the json and coredata terminology
    /*
     NSDictionary *attributes = [[event entity] attributesByName];
     for (NSString *attribute in attributes) {
     id value = [dictionary objectForKey:attribute];
     if (value == nil) {
     continue;
     }
     [event setValue:value forKey:attribute];
     }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPecks:(id)sender
{
    PAPecksViewController * controller = [self.storyboard instantiateViewControllerWithIdentifier:PAPecksIdentifier];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)insertNewObject:(id)sender
{
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
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
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Event *tempEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = tempEvent.title;
    NSString *imageID = tempEvent.id;
    UIImage *image = [imageCache objectForKey:imageID];
    if(image){
        cell.imageView.image=image;
    }else{
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData *data = tempEvent.photo;
            UIImage *image = [UIImage imageWithData:data];
            if(!image){
                image = [UIImage imageNamed:@"Silhouette.png"];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"image id: %@", imageID);
                [imageCache setObject:image forKey:imageID];
                cell.imageView.image =image;
                //reload the cell to display the image
                //this will be called at most one time for each cell
                //because the image will be loaded into the cache
                //after the first time
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            });
        });
    }
}

@end
