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
#import "PAFetchManager.h"
#import "PASyncManager.h"
#import "PAFriendProfileViewController.h"
#import "HTAutocompleteManager.h"
#import "PACommentCell.h"
#import "PAFriendProfileViewController.h"
#import "PAAssetManager.h"
#import "PAInvitationsTableViewController.h"

#define cellHeight 100.0
#define reloadTime 10
@interface PACirclesTableViewController ()

@property (strong, nonatomic) UIBarButtonItem * cancelCellButton;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeRecognizer;
@property (strong, nonatomic) NSMutableArray* addedPeers;

@property (strong, nonatomic) UIView * keyboardAccessoryView;
@property (strong, nonatomic) UITextField * keyboardAccessory;
@property (strong, nonatomic) UIButton * postButton;

@end

@implementation PACirclesTableViewController

@synthesize circles = _circles;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * cellIdentifier = PACirclesIdentifier;
static NSString * nibName = @"PACircleCell";

Peer* selectedPeer;
CGRect initialFrame;
CGRect initialCommentTableFrame;
NSInteger selectedCell;
Circle* selectedCircle;
BOOL viewingCell;
BOOL viewingCircles;

PAAssetManager *assetManager;

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

    assetManager = [PAAssetManager sharedManager];

    self.addedPeers = [[NSMutableArray alloc] init];
    viewingCell=NO;
    self.cancelCellButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelection)];
    
    //self.title = @"Circles";

    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // allows for the 1 pixel header to be ignored
    self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);    
    
    [self.tableView reloadData];

    UIView * accessory = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    accessory.backgroundColor = [UIColor whiteColor];

    self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    self.swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    self.swipeRecognizer.cancelsTouchesInView = NO;


    self.keyboardAccessoryView = [[UIView alloc] init];
    self.keyboardAccessoryView.backgroundColor = [UIColor whiteColor];

    self.keyboardAccessory = [assetManager createTextFieldWithFrame:CGRectZero];
    self.keyboardAccessory.placeholder = @"Post a comment...";
    self.keyboardAccessory.delegate = self;

    [self.keyboardAccessoryView addSubview:self.keyboardAccessory];

    self.postButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.postButton addTarget:self action:@selector(didSelectPostButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardAccessoryView addSubview:self.postButton];
    self.postButton.alpha = 0;
    
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    appdelegate.circleViewController = self;
}

-(void)viewWillAppear:(BOOL)animated {
    //when this is uncommented, a strange error occurs where the circle cell will scroll up when the comment cell is selected
    //[super viewWillAppear:animated];
    
    /*_fetchedResultsController=nil;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }*/

    
    [[PASyncManager globalSyncManager] updateCircleInfo];

    viewingCircles=YES;

    [self registerForKeyboardNotifications];

    initialFrame=self.tableView.frame;

    // TODO: This crashes sometimes
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (viewingCircles) {
            if (viewingCell && self.selectedIndexPath.row != [_fetchedResultsController.fetchedObjects count]) {
                //if you are viewing a cell that is not the final (create circle) cell
                PACircleCell *selectedCircleCell = (PACircleCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
                NSString* circleID =[selectedCircleCell.circle.id stringValue];
                [[PASyncManager globalSyncManager] updateCommentsFrom:circleID withCategory:@"circles"];
            }
            [NSThread sleepForTimeInterval:reloadTime];
        }
    });
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView reloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if(viewingCell){
        PACircleCell* cell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        //[self condenseCircleCell:cell atIndexPath:self.selectedIndexPath];
        [cell endEditing:YES];
        [self dismissKeyboard:self];
        [self dismissCircleTitleKeyboard];
    }
    viewingCircles=NO;
    [self deregisterFromKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSelectPostButton:(id)sender
{
    [self postComment:self.keyboardAccessory.text];
    [self dismissKeyboard:self];
    self.keyboardAccessory.text = @"";
}

#pragma mark - text field delegate

-(void)textFieldDidChange:(UITextField*)textField{
    /*
    NSLog(@"textfield text: %@",textField.text);
    //NSLog(@"row: %i, section: %i",[self.selectedIndexPath row], [self.selectedIndexPath section]);
    PACircleCell * selectedCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    selectedCell.suggestedMembers = [self suggestedMembers:textField.text];
    [selectedCell.suggestedMembersTableView reloadData];
     */
}

/*- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"add a new member");
    HTAutocompleteTextField *tempTextField = (HTAutocompleteTextField *)textField;
    [self addMemberWithTextField:tempTextField];
    return NO;
}
-(void)addMemberWithTextField:(HTAutocompleteTextField *)textField{
    Peer *tempPeer = [HTAutocompleteManager sharedManager].currentPeer;
    if(tempPeer){
        textField.text=@"";
        textField.autocompleteLabel.text=@"";
        Peer * tempPeer = [HTAutocompleteManager sharedManager].currentPeer;
        NSLog(@"new member id: %@", tempPeer.id);
        [textField forceRefreshAutocompleteText];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber* invited_by = [defaults objectForKey:@"user_id"];
        NSNumber* instituion_id = [defaults objectForKey:@"institution_id"];
        NSNumber* circle_id = selectedCircle.id;
        NSDictionary *newMember = [NSDictionary dictionaryWithObjectsAndKeys:
                                   invited_by, @"invited_by",
                                   tempPeer.id, @"user_id",
                                   instituion_id, @"institution_id",
                                   circle_id, @"circle_id",
                                    nil];
        [[PASyncManager globalSyncManager] postCircleMember:tempPeer withDictionary:newMember forCircle:selectedCircle withSender:self ];
    }
}
*/

-(void)addMember:(Peer*)newMember{
    PACircleCell* selectedCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    //selectedCell.suggestedMembers=nil;
    //[selectedCell.suggestedMembersTableView reloadData];
    
    if(self.selectedIndexPath.row!=[_fetchedResultsController.fetchedObjects count]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber* invited_by = [defaults objectForKey:@"user_id"];
        NSNumber* instituion_id = [defaults objectForKey:@"institution_id"];
        NSNumber* circle_id = selectedCircle.id;
        NSString* alert = [[defaults objectForKey:@"first_name"] stringByAppendingString:@" "];
        alert = [alert stringByAppendingString:[defaults objectForKey:@"last_name"]];
        alert = [alert stringByAppendingString:@" has invited you to a circle"];
        NSLog(@"message: %@", alert);
        NSDictionary *newCircleMember = [NSDictionary dictionaryWithObjectsAndKeys:
                                         invited_by, @"invited_by",
                                         newMember.id, @"user_id",
                                         instituion_id, @"institution_id",
                                         circle_id, @"circle_id",
                                         //@"6c6cfc215bdc2d7eeb93ac4581bc48f7eb30e641f7d8648451f4b1d3d1cde464",@"token",
                                         alert, @"message",
                                         //@"circle_invite", @"notification_type",
                                         [NSNumber numberWithBool:YES],@"send_push_notification",
                                         nil];
        //[[PASyncManager globalSyncManager] postCircleMember:newMember withDictionary:newCircleMember forCircle:selectedCircle withSender:selectedCell];
        
        
        //[[PASyncManager globalSyncManager] postPeck:newCircleMember];
        [[PASyncManager globalSyncManager] postCircleMember:newCircleMember];
        
    }else{
        [self.addedPeers addObject:newMember];
        [selectedCell updateCircleMembers:self.addedPeers];
    }
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 1.0f;
    return 32.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects]+1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self dismissKeyboard:self];
}


// TODO: Initialize cells with members
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACircleCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]  forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        initialCommentTableFrame=cell.commentsTableView.frame;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
  
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_fetchedResultsController.fetchedObjects count]) {
        return 44;
    }
    else if((self.selectedIndexPath != nil) && (indexPath.row == self.selectedIndexPath.row)) {
        return self.view.frame.size.height;
    }
    else {
        return cellHeight;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACircleCell *cell = (PACircleCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(!viewingCell){
        if(indexPath.row<[self.fetchedResultsController.fetchedObjects count]){
            [self expandCircleCell:cell atIndexPath:indexPath];
        }
        
        /*
        cell.addingMembers=NO;
        if(indexPath.row==[_fetchedResultsController.fetchedObjects count]){
            [cell updateCircleMembers:nil];
            cell.titleTextField.text=@"";
        }
        [cell performFetch];
        self.selectedIndexPath = indexPath;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

        self.tableView.scrollEnabled = NO;
        viewingCell=YES;
        self.keyboardAccessory.hidden = NO;
        self.keyboardAccessoryView.frame = CGRectMake(0, cell.frame.origin.y + cell.frame.size.height - 44, self.view.frame.size.width, 44);
        [self configureCell:cell atIndexPath:indexPath];
         */

    } else {
        if (cell.addingMembers) {
            if (indexPath.row == [_fetchedResultsController.fetchedObjects count]) {
                [self condenseCircleCell:cell atIndexPath:indexPath];
            } else {
                cell.addingMembers = NO;
                [self dismissKeyboard:self];
                [self configureCell:cell atIndexPath:indexPath];
                [cell performFetch];
                NSString* circleID = [cell.circle.id stringValue];
                [[PASyncManager globalSyncManager] updateCommentsFrom:circleID withCategory:@"circles"];
                [self addCommentTextFieldToCell:cell];
            }
        } else {
            //[self condenseCircleCell:cell atIndexPath:indexPath];
        }

    }
}

-(void)expandCircleCell:(PACircleCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    /*
    if(self.selectedIndexPath){
        if(self.selectedIndexPath != indexPath){
            //if another cell is expanded and the user is being linked to this cell from a peck
            PACircleCell* cell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
            [self condenseCircleCell:cell atIndexPath:self.selectedIndexPath];
        }
    }*/
    
    cell.addingMembers=NO;
    if(indexPath.row==[_fetchedResultsController.fetchedObjects count]){
        [cell updateCircleMembers:nil];
        cell.titleTextField.text=@"";
        [self.tableView setScrollEnabled:YES];
    }else{
        [self.tableView setScrollEnabled:NO];
    }
    [cell performFetch];
    self.selectedIndexPath = indexPath;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    //self.tableView.scrollEnabled = NO;
    viewingCell=YES;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    NSLog(@"configured the cell at index path: %li",(long)indexPath.row);
    
    NSString* circleID = [cell.circle.id stringValue];
    NSLog(@"get comments for circle: %@", circleID);
    [[PASyncManager globalSyncManager] updateCommentsFrom:circleID withCategory:@"circles"];
    
    [self addCommentTextFieldToCell:cell];
    
}

-(void)addCommentTextFieldToCell:(PACircleCell*)cell{
    self.keyboardAccessory.hidden = NO;
    self.keyboardAccessoryView.frame = CGRectMake(0, cell.frame.origin.y + cell.frame.size.height - 44, self.view.frame.size.width, 44);
    
    self.keyboardAccessoryView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.keyboardAccessory.frame = CGRectMake(7, 7, self.view.frame.size.width - 14, 30);
    self.postButton.frame = CGRectMake(self.keyboardAccessoryView.frame.size.width - self.keyboardAccessoryView.frame.size.height, 0, self.keyboardAccessoryView.frame.size.height, self.keyboardAccessoryView.frame.size.height);
    [cell addGestureRecognizer:self.swipeRecognizer];
    [cell addSubview:self.keyboardAccessoryView];
}

-(void)condenseCircleCell:(PACircleCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"condense cell for row: %li", (long)indexPath.row);
    [self dismissKeyboard:self];
    [self.addedPeers removeAllObjects];
    viewingCell=NO;
    self.keyboardAccessory.hidden = YES;
    [self.keyboardAccessory resignFirstResponder];
    self.tableView.scrollEnabled = YES;
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    cell.addingMembers=NO;
    [self.tableView reloadData];
    self.selectedIndexPath = nil;
    [self dismissKeyboard:self];
    if(indexPath){
        [self configureCell:cell atIndexPath:indexPath];
    }else{
        [cell.leaveCircleButton setHidden:YES];
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.keyboardAccessoryView removeFromSuperview];
    [cell removeGestureRecognizer:self.swipeRecognizer];
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

- (void)cancelSelection
{
    [self dismissKeyboard:self];
    viewingCell=NO;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    PACircleCell *selectedCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    selectedCell.addingMembers=NO;
    self.selectedIndexPath = nil;
    [self dismissKeyboard:self];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)configureCell:(PACircleCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.tag=[indexPath row];
    cell.parentViewController=self;
    if(indexPath.row==[_fetchedResultsController.fetchedObjects count]){
        cell.circleTitle.text=@"";
        [cell.profilesTableView setHidden:YES];
        [cell.commentsTableView setHidden:YES];
        //[cell.titleTextField setHidden:YES];
        //[cell.createCircleButton setHidden:YES];
        [cell.leaveCircleButton setHidden:YES];
        [cell.backButton setHidden:YES];
        [cell updateCircleMembers:nil];
        //if(viewingCell){
            [cell.titleTextField setHidden:NO];
            [cell.profilesTableView setHidden:NO];
            [cell.createCircleButton setHidden:NO];
            //[cell.backButton setHidden:NO];
        //}
        
    }
    else{
        [cell.titleTextField setHidden:YES];
        [cell.profilesTableView setHidden:NO];
        [cell.commentsTableView setHidden:NO];
        [cell.createCircleButton setHidden:YES];
        
        Circle * c = [_fetchedResultsController objectAtIndexPath:indexPath];
        //NSLog(@"configure cell for circle %@", c);
        cell.circleTitle.text = c.circleName;
        cell.delegate = self;
        [cell.leaveCircleButton setHidden:YES];
        [cell.backButton setHidden:YES];
        if(viewingCell){
            [cell.leaveCircleButton setHidden:NO];
            [cell.backButton setHidden:NO];
        }
        
        cell.circle=c;
        NSSet*members = c.circle_members;
        [cell updateCircleMembers:[members allObjects]];
    }

    [cell.profilesTableView reloadData];
}

- (IBAction)addCircle:(id)sender
{
    [self performSegueWithIdentifier:@"createACircle" sender:self];
}

# pragma mark - PACirclesControllerDelegate

/*-(void)profile:(int)member withCircle:(NSInteger)circle{
    
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
}*/

- (void)promptToAddMemberToCircleCell:(PACircleCell *)cell
{
    /*
    [cell.commentsTableView setHidden:YES];
    [cell.suggestedMembersTableView setHidden:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
    self.selectedIndexPath = indexPath;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.tableView.scrollEnabled = NO;
    viewingCell=YES;

    selectedCell=cell.tag;
    selectedCircle=cell.circle;
    // Look at how terrible this is.
    [self.textCapture becomeFirstResponder];
    [self.inviteTextField becomeFirstResponder];
    
    [self.keyboardAccessoryView removeFromSuperview];
    
    [self configureCell:cell atIndexPath:indexPath];
     */

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
    self.selectedIndexPath = indexPath;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.tableView.scrollEnabled = NO;
    viewingCell=YES;

    selectedCell=cell.tag;
    selectedCircle=cell.circle;

    [self configureCell:cell atIndexPath:indexPath];

    PAInvitationsTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"invitations"];
    [self presentViewController:vc animated:YES completion:^{}];
    vc.delegate = self;

    
    /*
    Peer *peer;
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (peer in cell.members) {
        [mutableDictionary setObject:peer.id forKey:[peer.id stringValue]];
    }

    vc.invitedPeople = mutableDictionary;
    vc.invitedCircles = nil;
     */

}

- (void)didInvitePeople:(NSMutableDictionary *)people andCircles:(NSMutableDictionary *)circles
{
    NSNumber *peerId;
    for (peerId in people) {
        [self addMember:[[PAFetchManager sharedFetchManager] getPeerWithID:peerId]];
    }
}

- (void)dismissKeyboard:(id)sender
{
    [self dismissCommentKeyboard];
    [self dismissCircleTitleKeyboard];
}

-(void)dismissCircleTitleKeyboard{
    PACircleCell* cell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell.titleTextField resignFirstResponder];
    
}
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"circleName" ascending:YES];
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
    NSLog(@"controller will change object");
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

        case NSFetchedResultsChangeMove:
            break;

        case NSFetchedResultsChangeUpdate:
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
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
            break;
            
        }
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

#pragma mark - managing the keyboard notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if(CGRectEqualToRect(self.tableView.frame, initialFrame)&&viewingCell==NO){
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-keyboardSize.height);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedCell inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if(viewingCell){
        /*PACircleCell *circleCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        if(CGRectEqualToRect(circleCell.commentsTableView.frame,initialCommentTableFrame)){
            NSLog(@"shorten the frame");
            //initialCommentTableFrame=circleCell.commentsTableView.frame;
            CGRect modifiedFrame = circleCell.commentsTableView.frame;
            modifiedFrame.size = CGSizeMake(modifiedFrame.size.width, modifiedFrame.size.height-keyboardSize.height);
            circleCell.commentsTableView.frame = modifiedFrame;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [circleCell.commentsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }*/
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];

    self.keyboardAccessoryView.frame = CGRectOffset(self.keyboardAccessoryView.frame, 0, -keyboardSize.height);
    self.keyboardAccessory.frame = CGRectMake(7, 7, self.view.frame.size.width - self.postButton.frame.size.width - 7, 30);
    self.postButton.alpha = 1;

    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];

    self.keyboardAccessoryView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.keyboardAccessory.frame = CGRectMake(7, 7, self.view.frame.size.width - 14, 30);
    self.postButton.alpha = 0;

    [UIView commitAnimations];
}

-(void)dismissCommentKeyboard{
    /*PACircleCell *circleCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    PACommentCell *commentCell = (PACommentCell*)[circleCell.commentsTableView cellForRowAtIndexPath:indexPath];
    [commentCell.commentTextView resignFirstResponder];*/
    [self.keyboardAccessory resignFirstResponder];

}

-(void)postComment:(NSString *)text
{
   
    if(![text isEqualToString:@""]){
        PACircleCell *selectedCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        // NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        // [selectedCell.commentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];

        NSLog(@"post the comment");
        //NSString *commentText = cell.commentTextView.text;
        self.keyboardAccessory.text = @"";
        
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *userID = [defaults objectForKey:@"user_id"];
        NSNumber *institutionID = [defaults objectForKey:@"institution_id"];
   
        NSString* alert = [defaults objectForKey:@"first_name"];
        alert = [alert stringByAppendingString:@" "];
        alert = [alert stringByAppendingString:[defaults objectForKey:@"last_name"]];
        alert = [alert stringByAppendingString:@" commented in "];
        alert = [alert stringByAppendingString:selectedCell.circle.circleName];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    text, @"content",
                                    userID, @"user_id",
                                    @"circles", @"category",
                                    selectedCell.circle.id, @"comment_from",
                                    institutionID, @"institution_id",
                                    [NSNumber numberWithBool:YES], @"send_push_notification",
                                    alert, @"message",
                                    //[defaults objectForKey:@"user_id"], @"invited_by",
                                    nil];
    
        [[PASyncManager globalSyncManager] postComment:dictionary];
        
        self.keyboardAccessory.text = @"";
    }
}



- (void)expandTableViewCell:(PACommentCell *)cell {
    NSLog(@"still expanding!!");
    PACircleCell *circleCell = (PACircleCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [circleCell expand:cell];
}

-(void)compressTableViewCell:(PACommentCell *)cell{
    PACircleCell *circleCell = (PACircleCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [circleCell compress:cell];
}


-(void)showProfileOf:(Peer *)member{
    selectedPeer=member;
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [loginStoryboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    PAFriendProfileViewController*root = navController.viewControllers[0];
    root.peer=member;
    [self presentViewController:navController animated:YES completion:nil];
    //[self performSegueWithIdentifier:@"selectProfile" sender:self];
}


-(NSMutableArray*)suggestedMembers:(NSString*)prefix{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", prefix];
    
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    NSArray* currentMembers = nil;
    if([_fetchedResultsController.fetchedObjects count]>self.selectedIndexPath.row){
        //if the user is adding members to an already created circle
        Circle* circle = [_fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
        NSSet* circleMembers = circle.circle_members;
        currentMembers = [circleMembers allObjects];
    }else{
        //if the user is creating a new circle
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_fetchedResultsController.fetchedObjects count] inSection:0];
        PACircleCell* cell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        currentMembers = cell.members;
        
    }
    
    for(int i = 0; i<[mutableFetchResults count];i++){
        Peer* peer = mutableFetchResults[i];
        for(Peer* member in currentMembers){
            if([peer.id integerValue]==[member.id integerValue]){
                [mutableFetchResults removeObjectAtIndex:i];
            }
        }
    }
    return mutableFetchResults;
}

@end
