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
#import "PAFetchManager.h"
#import "UIImageView+AFNetworking.h"



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
UITextView *textViewHelper;


BOOL reloaded = NO;

#define defaultCellHeight 51
#define cellY 22
#define reloadTime 10
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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.userPicture =[UIImage imageWithContentsOfFile:[defaults objectForKey:@"profile_picture"]];
    textViewHelper = [[UITextView alloc] init];
    [textViewHelper setHidden:YES];
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
            [[PASyncManager globalSyncManager] updateCommentsFrom:eventID withCategory:@"simple"];
            [NSThread sleepForTimeInterval:reloadTime];
        }
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    viewingEvent=NO;
    [self.view endEditing:YES];
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
       
        self.numberOfAttendees.text = [@([[self.detailItem valueForKey:@"attendees"] count]) stringValue];
        if([self attendingEvent]){
            [self.attendButton setTitle:@"Unattend" forState:UIControlStateNormal];
        }else{
            [self.attendButton setTitle:@"Attend" forState:UIControlStateNormal];
        }
        
        UIImage* image = [UIImage imageNamed:@"image-placeholder.png"];
        if([self.detailItem valueForKey:@"imageURL"]){
            [self.eventPhoto setImageWithURL:[NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:[self.detailItem valueForKey:@"imageURL"]]] placeholderImage:image];
        }else{
            self.eventPhoto.image = image;
        }
        
    }
}

-(BOOL)attendingEvent{
    NSArray* attendees = [self.detailItem valueForKey:@"attendees"];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [[defaults objectForKey:@"user_id"] integerValue];
    for(int i = 0; i<[attendees count];i++){
        if(userID==[attendees[i] integerValue]){
            return YES;
        }
    }
    return NO;
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
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category like %@", @"simple"];
    
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
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:([newIndexPath row]+1) inSection:[newIndexPath section] ];
            [tableView
             //the cell must be inserted below the post cell
             insertRowsAtIndexPaths:[NSArray arrayWithObject:realIndexPath]
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
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:([newIndexPath row]+1) inSection:[newIndexPath section]];
            
            PACommentCell * cell = (PACommentCell *)[tableView cellForRowAtIndexPath:realIndexPath];
            [self configureCell:cell atIndexPath:realIndexPath];
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
        [cell.likeButton setHidden:YES];
        [cell.numberOfLikesLabel setHidden:YES];
        [cell.commentTextView setEditable:YES];
        [cell.commentTextView setScrollEnabled:YES];
        [cell.postButton setHidden:NO];
        if(([self.commentText isEqualToString:@""] || self.commentText==nil) && ![cell.commentTextView isFirstResponder]){
            cell.commentTextView.textColor = [UIColor lightGrayColor];
            cell.commentTextView.text = @"add a comment";
        }
        else{
            cell.commentTextView.textColor = [UIColor blackColor];
            cell.commentTextView.text = self.commentText;
        }
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* userName = [[[defaults objectForKey:@"first_name"] stringByAppendingString:@" "] stringByAppendingString:[defaults objectForKey:@"last_name"]];
        cell.nameLabel.text=userName;
        [cell.expandButton setHidden:YES];
        cell.profilePicture.image = self.userPicture;
    }
    else{
        Comment *tempComment = _fetchedResultsController.fetchedObjects[[indexPath row]-1];
        cell.numberOfLikesLabel.text = [@([tempComment.likes count]) stringValue];
        [cell.likeButton setHidden:NO];
        [cell.numberOfLikesLabel setHidden:NO];

        if([self userHasLikedComment:tempComment]){
            [cell.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
        }else{
            [cell.likeButton setTitle:@"Like" forState:UIControlStateNormal];
        }
        
        cell.commentID = tempComment.id;
        cell.commentIntegerID = [tempComment.id integerValue];
        //cell.comment = tempComment;
        NSLog(@"self.detail: %@", [[self.detailItem valueForKey:@"id"] stringValue]);
        cell.comment_from = [[self.detailItem valueForKey:@"id"] stringValue];
        [cell.commentTextView setEditable:NO];
        [cell.commentTextView setScrollEnabled:NO];
        [cell.expandButton setHidden:NO];
        if([self textViewIsSmallerThanFrame:tempComment.content]){
            [cell.expandButton setHidden:YES];
        }
        [cell.postButton setHidden:YES];
        cell.nameLabel.text = [self nameLabelTextForComment:tempComment];
        cell.tag = [indexPath row]-1;
        cell.commentTextView.text = tempComment.content;
        [cell.commentTextView setTextColor:[UIColor blackColor]];
        
        [self imageForComment:tempComment withCell:cell];
        
        NSString * commentID = [tempComment.id stringValue];
        CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
        if(height){
            cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, height);
            cell.expanded=YES;
            [cell.expandButton setTitle:@"Hide" forState:UIControlStateNormal];
        }
        else{
            cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCellHeight);
            //using the default cell height used to show half a line, but now with autolayout constraints it displays correctly
            cell.expanded=NO;
            [cell.expandButton setTitle:@"More" forState:UIControlStateNormal];
        }
        
    }
    
}

-(BOOL)userHasLikedComment:(Comment*)comment{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [[defaults objectForKey:@"user_id"] integerValue];
    for(int i =0; i<[comment.likes count];i++){
        if(userID==[comment.likes[i] integerValue]){
            return YES;
        }
    }return NO;
}

-(NSString*)nameLabelTextForComment:(Comment*)comment{
    NSString* text = @"Unknown";
    if(comment.peer_id){
        Peer* tempPeer = [[PAFetchManager sharedFetchManager] getPeerWithID:comment.peer_id];;
        if(tempPeer){
            text=tempPeer.name;
        }
    }
    
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"comment id: %@ my id: %@",comment.peer_id, [defaults objectForKey:@"user_id"]);
    if([[defaults objectForKey:@"user_id"] integerValue]==[comment.peer_id integerValue]){
        text = [[defaults objectForKey:@"first_name"] stringByAppendingString:@" "];
        text = [text stringByAppendingString:[defaults objectForKey:@"last_name"]];
    }
    text = [text stringByAppendingString:@" "];
    text = [text stringByAppendingString:[self dateToString:comment.created_at]];
    
    return text;
}

-(void)imageForComment:(Comment*)comment withCell:(PACommentCell*)cell{
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    if([[defaults objectForKey:@"user_id"] integerValue]==[comment.peer_id integerValue]){
        cell.profilePicture.image =  self.userPicture;
    }else{
        Peer* commentFromPeer = [[PAFetchManager sharedFetchManager] getPeerWithID:comment.peer_id];
        if(commentFromPeer.imageURL){
            NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:commentFromPeer.imageURL]];
            UIImage* profPic = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
            if(profPic){
                cell.profilePicture.image = profPic;
            }
            else{
                [cell.profilePicture setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]];
            }

        }
        else{
            cell.profilePicture.image = [UIImage imageNamed:@"profile-placeholder.png"];
        }
    }
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


-(BOOL)textViewIsSmallerThanFrame:(NSString*)text{
    textViewHelper.frame = CGRectMake(0, 0, 222, 0);
    [textViewHelper setFont:[UIFont systemFontOfSize:14]];
    [textViewHelper setHidden:YES];
    textViewHelper.text = text;
    [textViewHelper sizeToFit];
    if(textViewHelper.frame.size.height>defaultCellHeight){
        return NO;
    }
    return YES;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row>0){
        if([_fetchedResultsController.fetchedObjects count]>=[indexPath row]){
            Comment *comment = _fetchedResultsController.fetchedObjects[[indexPath row]-1];
            NSString * commentID = [comment.id stringValue];
            CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
            if(height){
                return height+cellY;
            }
        }
    }
    return defaultCellHeight+cellY;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    PACommentCell *cell = (PACommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
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
    textViewHelper.frame = cell.commentTextView.frame;
    textViewHelper.text=cell.commentTextView.text;
    
    [textViewHelper setFont:[UIFont systemFontOfSize:14]];
    [textViewHelper sizeToFit];
    
    float newHeight = textViewHelper.frame.size.height;
    NSLog(@"new height: %f", newHeight);
    NSNumber *height = [NSNumber numberWithFloat: defaultCellHeight];
    if(textViewHelper.frame.size.height>defaultCellHeight){
        height = [NSNumber numberWithFloat:textViewHelper.frame.size.height+1];
        //without the +1, the bottom line would not be displayed
    }
    //Comment* comment = _fetchedResultsController.fetchedObjects[cell.tag];
    
    NSString * commentID = [cell.commentID stringValue];
    
    [heightDictionary setValue:height forKey:commentID];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)compressTableViewCell:(PACommentCell *)cell{
    
    //cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCellHeight);
    //Comment *comment = _fetchedResultsController.fetchedObjects[cell.tag];
    NSString *commentID = [cell.commentID stringValue];
    [heightDictionary removeObjectForKey:commentID];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)postComment:(PACommentCell *)cell{
    if(cell.commentTextView.textColor==[UIColor blackColor] && ![cell.commentTextView.text isEqualToString:@""]){
        [cell.commentTextView resignFirstResponder];
        self.commentText=nil;
        NSIndexPath* firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:firstCellIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
        NSLog(@"post comment");
        NSString *commentText = cell.commentTextView.text;
        cell.commentTextView.text=@"";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *userID = [defaults objectForKey:@"user_id"];
        NSNumber *institutionID = [defaults objectForKey:@"institution_id"];
    
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                commentText, @"content",
                                userID, @"user_id",
                                @"simple", @"category",
                                [self.detailItem valueForKey:@"id" ],@"comment_from",
                                institutionID, @"institution_id",
                                nil];
    
        [[PASyncManager globalSyncManager] postComment:dictionary];
        
    }
}


- (IBAction)attendButton:(id)sender {
    if([self.attendButton.titleLabel.text isEqualToString:@"Attend"]){
    
        NSLog(@"attend the event");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
        NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [defaults objectForKey:@"user_id"],@"user_id",
                                  [defaults objectForKey:@"institution_id"],@"institution_id",
                                  [self.detailItem valueForKey:@"id"],@"event_attended",
                                  @"simple", @"category",
                                  [defaults objectForKey:@"user_id"], @"added_by",
                                  nil];
    
        [[PASyncManager globalSyncManager] attendEvent:attendee];
    }else{
        NSLog(@"unattend the event");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self.detailItem valueForKey:@"id"], @"event_attended",
                                  [defaults objectForKey:@"institution_id"],@"institution_id",
                                  [defaults objectForKey:@"user_id"],@"user_id",
                                  @"simple", @"category",
                                  nil];
        
        [[PASyncManager globalSyncManager] unattendEvent: attendee];
        
    }
    
}

@end
