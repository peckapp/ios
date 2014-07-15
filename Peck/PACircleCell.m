//
//  PACircleCellTableViewCell.m
//  Peck
//
//  Created by John Karabinos on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACircleCell.h"
#import "PACirclesTableViewController.h"
#import "PAFriendProfileViewController.h"
#import "PAAppDelegate.h"
#import "Circle.h"
#import "PACircleScrollView.h"
#import "Peer.h"
#import "PACommentCell.h"
#import "Comment.h"

@interface PACircleCell ()

@end

@implementation PACircleCell
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString * commentCellIdentifier = @"CircleCommentCell";
NSString * commentCellNibName = @"PACommentCell";
NSMutableDictionary *heightDictionary;
UITextView *textViewHelper;

#define defaultCellHeight 120
#define compressedTextViewHeight 110
//the compressed text view height is used to avoid seeing half of the last line of the text view.
//It should be changed manually if the default text view height is changed

- (void)awakeFromNib
{
    // Initialization code

    /*[scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(800, 0)];
     */

    _loadedImages = NO;

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.profilesTableView.delegate = self;
    self.profilesTableView.dataSource = self;

    self.profilesTableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.profilesTableView.frame = CGRectMake(0, 44.0, self.frame.size.width, 44.0);

    self.commentsTableView.delegate=self;
    self.commentsTableView.dataSource=self;
    
    NSLog(@"frame height: %f", self.frame.size.height);
    //self.commentsTableView.frame = CGRectMake(0, 100, self.frame.size.width, self.frame.size.height-200);
    
    heightDictionary = [[NSMutableDictionary alloc] init];
    self.members = [[NSMutableArray alloc] init];
    textViewHelper = [[UITextView alloc] init];
    [textViewHelper setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        [self expand];
    }
    else {
        [self contract];
    }
}

-(void)selectProfile: (UIGestureRecognizer*) sender{
    //CGPoint tapPoint = [sender locationInView:scrollView];
    //NSLog(@"cell: %i, x location: %f", self.tag, tapPoint.x);
    //[_delegate profile:2];

    //get the cell and the picture that has been selected and open that profile
}


-(void)addImages: (NSArray *)members{
    /*
    //TODO: fix this code so that reloading the table view does not reallocate
    NSLog(@"number of members: %lu", (unsigned long)[members count]);
    if([members count] != self.scrollView.numberOfMembers){
        //TODO: this if statement is not very robust, unnecessary images will be added if one member is added to the circle.
        //consider changing it to if numberOfMembers==0 or something similar
        for(int i = 0; i <[members count]; i++){
            Peer *tempPeer = [self peer:members[i]];
            NSLog(@"adding an image");
        
            UIImage *image = [UIImage imageNamed:@"profile-placeholder.png"];
            NSString *name = tempPeer.name;
            //use the id's in members to get the correct images
            [self.scrollView addPeer:image WithName:name];
        }
    }_loadedImages=YES;
     */
}

-(void)updateCircleMembers:(NSMutableArray *)circleMembers{
    //we will use members to configure the cells of the members
    //it is an array of peers
    self.members=circleMembers;
    [self.profilesTableView reloadData];
}

- (void)addMember:(NSNumber *)member
{

}

- (void)expand
{
    // TODO: handle expansion
}

- (void)contract
{
    // TODO: handle contraction
}


#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.profilesTableView) {
        return [self.members count] + 1;
    }
    else if (tableView == self.commentsTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects]+1;
    }
    else {
        return 0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


#pragma mark Table view delegate

// TODO: display profile images on table cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"circleSubcell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"circleSubcell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

    

        if (indexPath.row == [self.members count]) {
            cell.backgroundColor = [UIColor blackColor];
        }
        else if (indexPath.row % 2 == 0) {
            cell.backgroundColor = [UIColor grayColor];
        }
        else {
            cell.backgroundColor = [UIColor lightGrayColor];
        }

        cell.transform = CGAffineTransformMakeRotation(M_PI_2);
        return cell;
    }
    else if (tableView == self.commentsTableView) {
        PACommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:commentCellNibName bundle:nil] forCellReuseIdentifier:commentCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        }
        [self configureCell:cell atIndexPath:indexPath];
        return cell;

        
    }
    else {
        return nil;
    }
}

-(void)configureCell:(PACommentCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.parentCircleTableView = self.parentViewController;
    cell.parentCell=self;
    cell.tag = indexPath.row-1;
    if([indexPath row]==0){
        [cell.commentTextView setEditable:YES];
        [cell.commentTextView setScrollEnabled:YES];
        [cell.postButton setHidden:NO];
        if([self.commentText isEqualToString:@""] || self.commentText==nil){
            cell.commentTextView.textColor = [UIColor lightGrayColor];
            cell.commentTextView.text = @"add a comment";
        }
        else{
            cell.commentTextView.textColor = [UIColor blackColor];
            cell.commentTextView.text = self.commentText;
        }

        cell.nameLabel.text = @"John Doe";
        [cell.expandButton setHidden:YES];
    }
    else{
        Comment *tempComment = _fetchedResultsController.fetchedObjects[[indexPath row]-1];
        [cell.commentTextView setEditable:NO];
        [cell.commentTextView setScrollEnabled:NO];
        [cell.expandButton setHidden:NO];
        if([self textViewIsSmallerThanFrame:tempComment.content]){
            [cell.expandButton setHidden:YES];
        }
        [cell.postButton setHidden:YES];
        cell.nameLabel.text = @"John Doe";
        cell.commentTextView.text = tempComment.content;
        [cell.commentTextView setTextColor:[UIColor blackColor]];
        
        NSString * commentID = [tempComment.id stringValue];
        CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
        if(height){
            cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, height);
            cell.expanded=YES;
            [cell.expandButton setTitle:@"Hide" forState:UIControlStateNormal];
        }
        else{
            float compressedHeight = compressedTextViewHeight;
            cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, compressedHeight);
            cell.expanded=NO;
            [cell.expandButton setTitle:@"More" forState:UIControlStateNormal];
        }
        // this fixes the problem where the comment text would occasionally be cut off when first loaded
    }
    cell.nameLabel.text = @"John Doe";
}
-(BOOL)textViewIsSmallerThanFrame:(NSString*)text{
    textViewHelper.frame = CGRectMake(0, 0, 98, 0);
    [textViewHelper setHidden:YES];
    textViewHelper.text = text;
    [textViewHelper sizeToFit];
    if(textViewHelper.frame.size.height>119){
        return NO;
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        return 44;
    }
    else if (tableView == self.commentsTableView) {
        if(indexPath.row>0){
            if([_fetchedResultsController.fetchedObjects count]>=[indexPath row]){
                Comment *comment = _fetchedResultsController.fetchedObjects[[indexPath row]-1];
                NSString * commentID = [comment.id stringValue];
                CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
                if(height){
                    return height;
                }
            }
        }
        return defaultCellHeight;

    }
    else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        if (indexPath.row == [self.members count]) {
            [self.delegate promptToAddMemberToCircleCell:self];
        }
        else{
            NSLog(@"view the member");
            PACirclesTableViewController *parent = (PACirclesTableViewController *) self.parentViewController;
            Peer *member = self.members[[indexPath row]];
            [parent showProfileOf:member];
        }
    }
    else if (tableView == self.commentsTableView) {
        [self.commentsTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {

    }
}
#pragma mark - managing the fetched results controller

-(NSFetchedResultsController *)fetchedResultsController{
    NSLog(@"configuring the fetched results controller (circle cell)");
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
    NSLog(@"circle ID: %@", self.circle.id);
    NSPredicate *commentFromPredicate = [NSPredicate predicateWithFormat:@"comment_from = %@", self.circle.id];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category like %@", @"circles"];
    
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
    [self.commentsTableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.commentsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.commentsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"did change object");
    UITableView *tableView = self.commentsTableView;
    
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
    [self.commentsTableView endUpdates];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(scrollView==self.commentsTableView){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.commentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        PACirclesTableViewController *parent = (PACirclesTableViewController*)self.parentViewController;
        [parent dismissCommentKeyboard];
    }
}

-(void)performFetch{
    self.fetchedResultsController=nil;
    NSError *error=nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.commentsTableView reloadData];
}

-(void)expand:(PACommentCell*)cell{
    NSLog(@"Expand cell");
    [cell.commentTextView sizeToFit];
    NSNumber *height = [NSNumber numberWithFloat: defaultCellHeight];
    if(cell.commentTextView.frame.size.height>defaultCellHeight){
        height = [NSNumber numberWithFloat:cell.commentTextView.frame.size.height];
    }
    Comment* comment = _fetchedResultsController.fetchedObjects[cell.tag];
    
    NSString * commentID = [comment.id stringValue];
    
    [heightDictionary setValue:height forKey:commentID];
    [self.commentsTableView beginUpdates];
    [self.commentsTableView endUpdates];

}
-(void)compress:(PACommentCell*)cell{
    cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCellHeight);
    Comment *comment = _fetchedResultsController.fetchedObjects[cell.tag];
    NSString *commentID = [comment.id stringValue];
    [heightDictionary removeObjectForKey:commentID];
    [self.commentsTableView beginUpdates];
    [self.commentsTableView endUpdates];

}
@end
