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
#import "Peer.h"
#import "PACommentCell.h"
#import "Comment.h"
#import "PASyncManager.h"
#import "PAFetchManager.h"
#import "UIImageView+AFNetworking.h"
#import "PAAssetManager.h"
#import "PAMethodManager.h"

@interface PACircleCell ()

@end

@implementation PACircleCell
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSMutableDictionary *heightDictionary;
UITextView *textViewHelper;

PAAssetManager * assetManager;

#define defaultCellHeight 51
#define cellY 22
//the compressed text view height is used to avoid seeing half of the last line of the text view.
//It should be changed manually if the default text view height is changed

- (void)awakeFromNib
{
    assetManager = [PAAssetManager sharedManager];
    _loadedImages = NO;

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.profilesTableView.delegate = self;
    self.profilesTableView.dataSource = self;

    self.profilesTableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.profilesTableView.frame = CGRectMake(0, 40.0, self.frame.size.width, 52.0);
    self.profilesTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);

    self.commentsTableView.delegate=self;
    self.commentsTableView.dataSource=self;
    
    
    //NSLog(@"the superview height: %f", self.b);
    //self.commentsTableView.frame = CGRectMake(0, 0, self.superview.frame.size.width, <#CGFloat height#>)
    
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
    self.members = circleMembers;
    [self.profilesTableView reloadData];
}


#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(tableView==self.commentsTableView){
        return @"Comments";
    }else{
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView==self.profilesTableView){
        return 0;
    }
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.profilesTableView) {
        return [self.members count] + 1;
    }
    else if (tableView == self.commentsTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"profilePreviewCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profilePreviewCell"];
        }

        [self configureMemberCell:cell atIndexPath:indexPath];

        cell.transform = CGAffineTransformMakeRotation(M_PI_2);
        return cell;
    }
    else if (tableView == self.commentsTableView) {
        PACommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"PACommentCell" bundle:nil] forCellReuseIdentifier:@"commentCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        }
        [self configureCommentCell:cell atIndexPath:indexPath];
        return cell;
    }
    else {
        return nil;
    }
}

- (void)configureMemberCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIView * thumbnail = nil;
    if (indexPath.row == [self.members count]) {
        thumbnail = [assetManager createThumbnailWithFrame:cell.frame imageView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus"]]];
    }
    else {
        Peer* peer = self.members[indexPath.row];
        thumbnail = [assetManager createThumbnailWithFrame:cell.frame imageView:[self imageForPeerID:peer.id]];
    }

    thumbnail.userInteractionEnabled = NO;
    cell.backgroundView = thumbnail;
}

- (void)configureSuggestedMemberCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    Peer * suggestedMember = self.suggestedMembers[indexPath.row];
    NSLog(@"name: %@", suggestedMember.name);
    cell.textLabel.text = suggestedMember.name;
}

- (void)configureCommentCell:(PACommentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"configure cell");
    cell.parentCircleTableView = self.parentViewController;
    cell.parentCell=self;
    cell.tag = indexPath.row;
    /*
    if([indexPath row] == 0){
        
        [cell.likeButton setHidden:YES];
        [cell.numberOfLikesLabel setHidden:YES];
        [cell.commentTextView setEditable:YES];
        [cell.commentTextView setScrollEnabled:YES];
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
        // cell.profilePicture.image = self.userPicture;
    }
     */
        Comment *tempComment = _fetchedResultsController.fetchedObjects[indexPath.row];
        cell.numberOfLikesLabel.text = [@([tempComment.likes count]) stringValue];
        [cell.likeButton setHidden:NO];
        [cell.numberOfLikesLabel setHidden:NO];
    cell.commentor_id = tempComment.peer_id;
        
        if([self userHasLikedComment:tempComment]){
            [cell.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
        }else{
            [cell.likeButton setTitle:@"Like" forState:UIControlStateNormal];
        }
        
        cell.commentID = tempComment.id;
        cell.commentIntegerID = [tempComment.id integerValue];
        cell.comment_from = [self.circle.id stringValue];
        [cell.commentTextView setEditable:NO];
        [cell.commentTextView setScrollEnabled:NO];
        cell.nameLabel.text=[self nameLabelTextForComment:tempComment];
        
        cell.commentTextView.text = tempComment.content;
        [cell.commentTextView setTextColor:[UIColor blackColor]];

        UIImageView * thumbnail = [assetManager createThumbnailWithFrame:cell.thumbnailViewTemplate.frame imageView:[self imageForPeerID:tempComment.peer_id]];
        if (cell.thumbnailView) {
            [cell.thumbnailView removeFromSuperview];
        }
        [cell addSubview:thumbnail];
        cell.thumbnailView = thumbnail;

        
        NSString * commentID = [tempComment.id stringValue];
        CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
        if(height){
            cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, height);
            cell.expanded=YES;
        }
        else{
            cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCellHeight);
            cell.expanded=NO;
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

- (UIImageView *)imageForPeerID:(NSNumber*)peerID
{
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    NSURL* imageURL;
    if([[defaults objectForKey:@"user_id"] integerValue]==[peerID integerValue]){
        //return self.userPicture;
        imageURL = [NSURL URLWithString:[defaults objectForKey:@"profile_picture_url"]];
    }
    else {
        Peer * peer = [[PAFetchManager sharedFetchManager] getPeerWithID:peerID];
        if (peer.imageURL) {
            imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:peer.imageURL]];
        }else{
            imageURL=nil;
        }
    }
    if(imageURL){
        UIImage* image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
        if(image){
            return [[UIImageView alloc] initWithImage:image];
        }
        else {
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:imageURL placeholderImage:[assetManager profilePlaceholder]];
            return imageView;
        }
    }
    else {
        return [[UIImageView alloc] initWithImage:[assetManager profilePlaceholder]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        return 52;
    }
    else if (tableView == self.commentsTableView) {
        if(indexPath.row>0){
            if([_fetchedResultsController.fetchedObjects count]>[indexPath row]){
                Comment *comment = _fetchedResultsController.fetchedObjects[[indexPath row]];
                NSString * commentID = [comment.id stringValue];
                CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
                if(height){
                    return height+cellY;
                }
            }
        }
        return defaultCellHeight+cellY;


    }    else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        if (indexPath.row == [self.members count]) {
            self.addingMembers=YES;
            PACirclesTableViewController* parent= (PACirclesTableViewController*)self.parentViewController;
            [parent promptToAddMemberToCircleCell:self];
        }
        else{
            PACirclesTableViewController *parent = (PACirclesTableViewController *) self.parentViewController;
            Peer *member = self.members[[indexPath row]];
            NSLog(@"view the member %@", member.name);
            [parent showProfileOf:member];
        }
        [self.profilesTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (tableView == self.commentsTableView) {
        [self.commentsTableView deselectRowAtIndexPath:indexPath animated:YES];
        PACommentCell * cell = (PACommentCell *)[self tableView:self.commentsTableView cellForRowAtIndexPath:indexPath];
        if (cell.expanded) {
            [self compress:cell];
            cell.expanded = NO;
        }
        else {
            [self expand:cell];
            cell.expanded = YES;
        }

    }

    else {

    }
    // self.frame = CGRectMake(0, -44, self.frame.size.width, self.frame.size.height);
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
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:([newIndexPath row]) inSection:[newIndexPath section] ];
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
            NSIndexPath *realIndexPath = [NSIndexPath indexPathForRow:([newIndexPath row]) inSection:[newIndexPath section] ];
            PACommentCell * cell = (PACommentCell *)[tableView cellForRowAtIndexPath:realIndexPath];
            [self configureCommentCell:cell atIndexPath:realIndexPath];
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
        // NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        // [self.commentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
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
    textViewHelper.frame = cell.commentTextView.frame;
    textViewHelper.text=cell.commentTextView.text;
    
    [textViewHelper setFont:[UIFont systemFontOfSize:14]];
    [textViewHelper sizeToFit];
    
    
    NSNumber *height = [NSNumber numberWithFloat: defaultCellHeight];
    if(textViewHelper.frame.size.height>defaultCellHeight){
        height = [NSNumber numberWithFloat:textViewHelper.frame.size.height+1];
    }
    //Comment* comment = cell.comment; //_fetchedResultsController.fetchedObjects[cell.tag];
    
    NSString * commentID = [cell.commentID stringValue];
    
    [heightDictionary setValue:height forKey:commentID];
    [self.commentsTableView beginUpdates];
    [self.commentsTableView endUpdates];

}
-(void)compress:(PACommentCell*)cell{
    //cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCellHeight);
    
    //Comment *comment = cell.comment;//_fetchedResultsController.fetchedObjects[cell.tag];
    NSString *commentID = [cell.commentID stringValue];
    [heightDictionary removeObjectForKey:commentID];
    [self.commentsTableView beginUpdates];
    [self.commentsTableView endUpdates];

}
- (IBAction)leaveCircleButton:(id)sender {
    PACirclesTableViewController* parent = (PACirclesTableViewController*) self.parentViewController;
    [parent condenseCircleCell:self atIndexPath:nil];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [defaults objectForKey:@"user_id"],@"user_id",
                                self.circle.id, @"circle_id",
                                nil];
    [[PASyncManager globalSyncManager] leaveCircle:dictionary];
}

- (IBAction)backButton:(id)sender {
    PACirclesTableViewController* parent = (PACirclesTableViewController*) self.parentViewController;
    if(parent.selectedIndexPath){
        //There should always be a selected index path if we are pressing the back button
        [parent condenseCircleCell:self atIndexPath:parent.selectedIndexPath];
    }
}


// TODO: this should really be in the text field return button
- (IBAction)createCircleButton:(id)sender {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"authentication_token"]){
    
        NSNumber* userID = [defaults objectForKey:@"user_id"];
        NSNumber* institutionID= [defaults objectForKey:@"institution_id"];
    
        NSMutableArray* circleMembers = [[NSMutableArray alloc] init];
    
        for(int i=0;i<[self.members count];i++){
            Peer * tempPeer = self.members[i];
            [circleMembers addObject:tempPeer.id];
        }
        //[circleMembers addObject:[defaults objectForKey:@"user_id"]];
    
        NSString* alert = [[defaults objectForKey:@"first_name"] stringByAppendingString:@" "];
        alert = [alert stringByAppendingString:[defaults objectForKey:@"last_name"]];
        alert = [alert stringByAppendingString:@" has invited you to a circle"];
    
        NSDictionary * newCircle = [NSDictionary dictionaryWithObjectsAndKeys:
                                    userID, @"user_id",
                                    institutionID, @"institution_id",
                                    self.titleTextField.text, @"circle_name",
                                    circleMembers, @"circle_member_ids",
                                    alert, @"message",
                                    nil];
    
        [self endEditing:YES];
        PACirclesTableViewController* parent = (PACirclesTableViewController*)self.parentViewController;
        [parent dismissCircleTitleKeyboard];
        [parent dismissKeyboard:self];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[parent.fetchedResultsController.fetchedObjects count] inSection:0];
        [parent condenseCircleCell:self atIndexPath:indexPath];
    
        [[PASyncManager globalSyncManager] postCircle:newCircle];
    }else{
        [[PAMethodManager sharedMethodManager]showRegisterAlert:@"create a circle" forViewController:self.parentViewController];
    }
    
}
@end
