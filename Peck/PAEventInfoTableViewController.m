//
//  PAEventInfoTableViewController.m
//  Peck
//
//  Created by John Karabinos on 7/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//


#import "PAEventInfoTableViewController.h"
#import "PACommentCell.h"
#import "PAAppDelegate.h"
#import "PASyncManager.h"
#import "Comment.h"
@interface PAEventInfoTableViewController ()

-(void)configureCell:(PACommentCell *)cell atIndexPath: (NSIndexPath *)indexPath;
@property (nonatomic, retain) NSDateFormatter *formatter;

@end

@implementation PAEventInfoTableViewController

@synthesize startTimeLabel = _startTimeLabel;
@synthesize endTimeLabel = _endTimeLabel;
@synthesize descriptionTextView = _blurbTextView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString * cellIdentifier = @"CommentCell";
NSString * nibName = @"PACommentCell";
NSMutableDictionary *heightDictionary;
CGRect initialFrame;
BOOL viewingEvent;

BOOL reloaded = NO;

#define reloadTime 3
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //if(!self.formatter){
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
    //}
    
    [self.descriptionTextView setEditable:NO];
    [self configureView];
    heightDictionary = [[NSMutableDictionary alloc] init];
    NSError * error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    [self.tableView reloadData];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    viewingEvent=YES;
    [self registerForKeyboardNotifications];
    NSString *eventID = [[self.detailItem valueForKey:@"id"] stringValue];
    initialFrame = self.tableView.frame;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while(viewingEvent) {
            [[PASyncManager globalSyncManager] updateCommentsFrom:eventID withCategory:@"simple_event"];
            [NSThread sleepForTimeInterval:reloadTime];
        }
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    viewingEvent=NO;
    [self deregisterFromKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - managing the keyboard notifications

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
    if(CGRectEqualToRect(self.tableView.frame, initialFrame)){
        NSDictionary* info = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-keyboardSize.height);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
        self.tableView.frame = initialFrame;
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
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *stringFromDate =[df stringFromDate:[self.detailItem valueForKey:@"start_date"]];
        [self.startTimeLabel setText: stringFromDate];
        [self.endTimeLabel setText:[df stringFromDate:[self.detailItem valueForKey:@"end_date"]]];
        self.descriptionTextView.text = [self.detailItem valueForKey:@"descrip"];
    }
}

#pragma mark - managing the fetched results controller

-(NSFetchedResultsController *)fetchedResultsController{
    NSLog(@"configuring the fetched results controller");
    if(_fetchedResultsController){
        return _fetchedResultsController;
    }
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSMutableArray *predicateArray =[[NSMutableArray alloc] init];
    
    NSPredicate *commentFromPredicate = [NSPredicate predicateWithFormat:@"comment_from = %@", [self.detailItem valueForKey:@"id"]];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category like %@", @"simple_event"];
    
    [predicateArray addObject:commentFromPredicate];
    [predicateArray addObject:categoryPredicate];
    
    NSPredicate *compoundPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [fetchRequest setPredicate:compoundPredicate];
    
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
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([newIndexPath row]+1) inSection:[newIndexPath section] ];
            [tableView
             //the cell must be inserted below the post cell
             insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            PACommentCell * cell = (PACommentCell *)[tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            break;
        }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects]+1;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(PACommentCell *)cell atIndexPath: (NSIndexPath *)indexPath{
    NSLog(@"configure cell");
    cell.parentTableView=self;
    if([indexPath row]==0){
        //if it is the first cell. This is where the user will add a comment
        [cell.commentTextView setEditable:YES];
        [cell.commentTextView setScrollEnabled:YES];
        [cell.postButton setHidden:NO];
        cell.commentTextView.text = @"";
        cell.nameLabel.text = @"John Doe";
        [cell.expandButton setHidden:YES];
        
    }
    else{
        Comment *tempComment = _fetchedResultsController.fetchedObjects[[indexPath row]-1];
        [cell.commentTextView setEditable:NO];
        [cell.commentTextView setScrollEnabled:NO];
        [cell.expandButton setHidden:NO];
        [cell.postButton setHidden:YES];
        cell.nameLabel.text = @"John Doe";
        cell.tag = [indexPath row];
        cell.commentTextView.text = tempComment.content;
    }
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"height for row at index path");
    //CGFloat height = ((PACommentCell*)[tableView cellForRowAtIndexPath:indexPath]).commentTextView.contentSize.height;
    NSString * cellTag = [@([indexPath row]) stringValue];
    
    CGFloat height = [[heightDictionary valueForKey:cellTag] floatValue];
    if(height){
        NSLog(@"setting the new height of the frame %f", height);
        return height;
    }
    return 120;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    PACommentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.commentTextView resignFirstResponder];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)expandTableViewCell:(PACommentCell *)cell {
    [cell.commentTextView sizeToFit];
    //[cell.commentTextView layoutSubviews];
    NSNumber *height = [NSNumber numberWithFloat:120];
    if(cell.commentTextView.frame.size.height>120){
        height = [NSNumber numberWithFloat:cell.commentTextView.frame.size.height];
    }
    NSString * cellTag = [@(cell.tag) stringValue];
    [heightDictionary setValue:height forKey:cellTag];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)compressTableViewCell:(PACommentCell *)cell{
    cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, 119);
    NSString *cellTag = [@(cell.tag) stringValue];
    [heightDictionary removeObjectForKey:cellTag];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)postComment:(PACommentCell *)cell{
    NSLog(@"post comment");
    NSString *commentText = cell.commentTextView.text;
    cell.commentTextView.text=@"";
    [cell.commentTextView resignFirstResponder];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [defaults objectForKey:@"user_id"];
    NSNumber *institutionID = [defaults objectForKey:@"institution_id"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                commentText, @"content",
                                userID, @"user_id",
                                @"simple_event", @"category",
                                [self.detailItem valueForKey:@"id" ],@"comment_from",
                                institutionID, @"institution_id",
                                nil];
    
    [[PASyncManager globalSyncManager] postComment:dictionary];
    [self reloadComments];
}

-(void)reloadComments{
    
    
}

@end
