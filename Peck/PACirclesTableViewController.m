//
//  PACirclesTableViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACirclesTableViewController.h"
#import "PACircleCell.h"
#import "PAAppDelegate.h"
#import "Circle.h"
#import "PASyncManager.h"
#import "PAFriendProfileViewController.h"

#define cellHeight 100.0

@interface PACirclesTableViewController ()

@property NSIndexPath * selectedIndexPath;
@property UIBarButtonItem * cancelCellButton;

@end

@implementation PACirclesTableViewController

@synthesize circles = _circles;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * cellIdentifier = PACirclesIdentifier;
static NSString * nibName = @"PACircleCell";

Peer* selectedPeer;

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

    self.cancelCellButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelection)];
    
    self.title = @"Circles";

    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [[PASyncManager globalSyncManager] updateCircleInfo];
    [self.tableView reloadData];
    
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// TODO: Initialize cells with members
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACircleCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]  forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
  
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((self.selectedIndexPath != nil) && (indexPath.row == self.selectedIndexPath.row)) {
        return self.view.frame.size.height;
    }
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    self.navigationItem.leftBarButtonItem = self.cancelCellButton;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.tableView.scrollEnabled = NO;
}

- (void)cancelSelection
{
    self.tableView.scrollEnabled = YES;
    self.navigationItem.leftBarButtonItem = nil;
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];

    self.selectedIndexPath = nil;

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)configureCell:(PACircleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Circle * c = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.circleTitle.text = c.circleName;

    /*if([cell.members count]!=[c.members count])
        [c.members enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [cell addMember:c.members[idx]];
    }];*/
    [cell updateCircleMembers:c.members];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (IBAction)addCircle:(id)sender
{
    [self performSegueWithIdentifier:@"createACircle" sender:self];
}

# pragma mark - PACirclesControllerDelegate

-(void)profile:(int)member withCircle:(NSInteger)circle{
    
    NSLog(@"you have selected user %i", member);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:circle inSection:0];
    Circle *tempCircle = [_fetchedResultsController objectAtIndexPath:indexPath];
    if([tempCircle.members count]>member){
        //in case the user presses to the right of the users in the scroll view
        
        NSNumber *userID = tempCircle.members[member];
    
        PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appdelegate managedObjectContext];
    
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
    
        NSString *attributeName = @"id";
        NSNumber *attributeValue = userID;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
        [fetchRequest setPredicate:predicate];
    
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        Peer *peer = mutableFetchResults[0];
    
        NSLog(@"the selected peer: %@", peer);
        selectedPeer = peer;
        [self performSegueWithIdentifier:@"selectProfile" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}



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

#pragma mark - Navigation

- (IBAction)unwindToCirclesViewController:(UIStoryboardSegue *)unwindSegue
{

}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if([[segue identifier] isEqualToString:@"selectProfile"]){
        NSManagedObject *object = selectedPeer;
        [[segue destinationViewController] setDetailItem:object];
    }
}


#pragma mark - Fetched Results controller

-(NSFetchedResultsController *)fetchedResultsController{
    NSLog(@"Returning the normal controller");
    if(_fetchedResultsController!=nil){
        return _fetchedResultsController;
    }
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSString * eventString = @"Circle";
    NSEntityDescription *entity = [NSEntityDescription entityForName:eventString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"circleName" ascending:NO];
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
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PACircleCell*)[tableView cellForRowAtIndexPath:indexPath]
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
    [self.tableView endUpdates];
}


@end
