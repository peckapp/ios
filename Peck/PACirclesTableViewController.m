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
#import "HTAutocompleteManager.h"
#import "PACommentCell.h"

#define cellHeight 100.0
#define reloadTime 3
@interface PACirclesTableViewController ()

@property (strong, nonatomic) NSIndexPath * selectedIndexPath;
@property (strong, nonatomic) UIBarButtonItem * cancelCellButton;
@property (strong, nonatomic) HTAutocompleteTextField * inviteTextField;
@property (strong, nonatomic) UITextField * textCapture;
@property (strong, nonatomic) UITapGestureRecognizer * tapRecognizer;

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    
    viewingCircles=YES;
    [self registerForKeyboardNotifications];
    initialFrame=self.tableView.frame;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while(viewingCircles){
            if(viewingCell){
                PACircleCell *selectedCircleCell = (PACircleCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
                NSString* circleID =[selectedCircleCell.circle.id stringValue];
                [[PASyncManager globalSyncManager] updateCommentsFrom:circleID withCategory:@"circles"];
                [NSThread sleepForTimeInterval:reloadTime];
                
            }
        }
    });

}
-(void)viewWillDisappear:(BOOL)animated{
    viewingCircles=NO;
    [self deregisterFromKeyboardNotifications];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    viewingCell=NO;
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

    UIView * accessory = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    accessory.backgroundColor = [UIColor whiteColor];

    self.inviteTextField = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(8.0, 8.0, self.view.frame.size.width - 16.0 , 28.0)];
    self.inviteTextField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.inviteTextField.autocompleteType = HTAutocompleteTypeName;
    self.inviteTextField.backgroundColor = [UIColor whiteColor];
    self.inviteTextField.placeholder = @"Invite someone to the group";
    [self.inviteTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.inviteTextField setReturnKeyType:UIReturnKeySend];
    self.inviteTextField.delegate=self;
    
    [accessory addSubview:self.inviteTextField];

    // Stupid workaround for letting buttons capture keyboard input
    self.textCapture = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.textCapture.hidden = YES;
    self.textCapture.inputAccessoryView = accessory;
    [self.view addSubview:self.textCapture];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //TODO: this is where we will send a new member to a circle that is already created
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
        [[PASyncManager globalSyncManager] postCircleMember:newMember forCircle:selectedCircle withSender:self];
    }

    
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
    if((self.selectedIndexPath != nil) && (indexPath.row == self.selectedIndexPath.row)) {
        return self.view.frame.size.height;
    }
    return cellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACircleCell *cell = (PACircleCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell performFetch];
    self.selectedIndexPath = indexPath;
    self.navigationItem.leftBarButtonItem = self.cancelCellButton;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.tableView.scrollEnabled = NO;
    viewingCell=YES;
    
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
    [self dismissCommentKeyboard];
    viewingCell=NO;
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
    //NSLog(@"configure cell for circle %@", c);
    cell.circleTitle.text = c.circleName;
    cell.delegate = self;
    cell.tag=[indexPath row];
    cell.parentViewController=self;
    cell.circle=c;
    NSSet*members = c.circle_members;
    [cell updateCircleMembers:[members allObjects]];
    NSArray *peers = [c.circle_members allObjects];
    NSLog(@"circle: %@",c.circleName);
    for(int j =0; j<[peers count]; j++){
        Peer *temp = peers[j];
        NSLog(@"member: %@",temp.id);
    }

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

- (void)promptToAddMemberToCircleCell:(PACircleCell *)cell
{
    NSLog(@"!!!");
    selectedCell=cell.tag;
    selectedCircle=cell.circle;
    // Look at how terrible this is.
    [self.textCapture becomeFirstResponder];
    [self.inviteTextField becomeFirstResponder];
}

- (void)dismissKeyboard:(id)sender
{
    NSLog(@"???");
    [self.inviteTextField resignFirstResponder];
    [self.textCapture resignFirstResponder];
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
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if(CGRectEqualToRect(self.tableView.frame, initialFrame)&&viewingCell==NO){
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-keyboardSize.height);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedCell inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if(viewingCell){
        PACircleCell *circleCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        if(CGRectEqualToRect(circleCell.commentsTableView.frame,initialCommentTableFrame)){
            NSLog(@"shorten the frame");
            //initialCommentTableFrame=circleCell.commentsTableView.frame;
            CGRect modifiedFrame = circleCell.commentsTableView.frame;
            modifiedFrame.size = CGSizeMake(modifiedFrame.size.width, modifiedFrame.size.height-keyboardSize.height);
            circleCell.commentsTableView.frame = modifiedFrame;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [circleCell.commentsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    if(viewingCell){
        PACircleCell *circleCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        circleCell.commentsTableView.frame=initialCommentTableFrame;
    }
    
    self.tableView.frame = initialFrame;
}

-(void)dismissCommentKeyboard{
    PACircleCell *circleCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    PACommentCell *commentCell = (PACommentCell*)[circleCell.commentsTableView cellForRowAtIndexPath:indexPath];
    [commentCell.commentTextView resignFirstResponder];
}

-(void)postComment:(PACommentCell *)cell{
    NSLog(@"post the comment");
    NSString *commentText = cell.commentTextView.text;
    cell.commentTextView.text=@"";
    [cell.commentTextView resignFirstResponder];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [defaults objectForKey:@"user_id"];
    NSNumber *institutionID = [defaults objectForKey:@"institution_id"];
    PACircleCell *selectedCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                commentText, @"content",
                                userID, @"user_id",
                                @"circles", @"category",
                                selectedCell.circle.id, @"comment_from",
                                institutionID, @"institution_id",
                                nil];
    
    [[PASyncManager globalSyncManager] postComment:dictionary];
}

- (void)expandTableViewCell:(PACommentCell *)cell {
    NSLog(@"still expanding!!");
    PACircleCell *circleCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [circleCell expand:cell];
}

-(void)compressTableViewCell:(PACommentCell *)cell{
    PACircleCell *circleCell = (PACircleCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [circleCell compress:cell];
}


-(void)showProfileOf:(Peer *)member{
    selectedPeer=member;
    [self performSegueWithIdentifier:@"selectProfile" sender:self];
}


@end
