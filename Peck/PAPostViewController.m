//
//  PAPostViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPostViewController.h"
#import "PAAppDelegate.h"
#import "Event.h"
#import "PADropdownViewController.h"
#import "PAPeers.h"
#import "PAImageManager.h"
#import "PASessionManager.h"
#import "PASyncManager.h"
#import "PAInvitationsTableViewController.h"
#import "PAFetchManager.h"
#import "UIImageView+AFNetworking.h"

/*
 State for each cell is defined by the cell's tag.
 Only show the cell if the tag is the same as the
 value of the control switch, or the same as the
 value of cellStateAlwaysOn.
 */
#define cellStateAlwaysOff -2
#define cellStateAlwaysOn -1

#pragma mark Interface

@interface PAPostViewController () {

    
}

@property BOOL startPickerIsOpen;
@property BOOL endPickerIsOpen;
@property CGRect initialTableViewFrame;

@end

#pragma mark - Implementation

@implementation PAPostViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize formatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    //[self.photo addTarget:self action:@selector(onPhotoSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.controlSwitch addTarget:self action:@selector(onControlSwitchChange) forControlEvents:UIControlEventValueChanged];
    
    self.locationTextField.delegate = self;
    
    [self.startTimePicker addTarget:self action:@selector(dateChanged:)forControlEvents:UIControlEventValueChanged];
    
    [self.endTimePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
    
    
    self.titleField.delegate = self;
    self.descriptionTextView.delegate = self;
    self.locationTextField.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _initialTableViewFrame = self.tableView.frame;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoSelect)];
    tgr.cancelsTouchesInView = NO;
    [self.photo addGestureRecognizer:tgr];
    self.photo.userInteractionEnabled = YES;

    
    //[self registerForKeyboardNotifications];
    
    if([self.controllerStatus isEqualToString:@"editing event"]){
        //if the user is editing an event rather than attempting to post one
        [self configureEventEditingView];
    }
    
    else if([self.controllerStatus isEqualToString:@"editing announcement"]){
        //if the user is editing an announcement
        [self configureAnnouncementEditingView];
    }
    
    NSLog(@"description text: %@", self.descriptionTextView.text);
    if([self.descriptionTextView.text isEqualToString:@""] || self.descriptionTextView.text==nil){
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
        self.descriptionTextView.text = @"Description";
    }
    
    if([self.invitedCircles count]+[self.invitedPeople count]==0){
        self.peopleLabel.text=@"None";
    }else{
        if([self.invitedCircles count]==1){
            self.peopleLabel.text = [[@([self.invitedCircles count]) stringValue] stringByAppendingString:@" circle, "];
        }else{
            self.peopleLabel.text = [[@([self.invitedCircles count]) stringValue] stringByAppendingString:@" circles, "];
        }
        if([self.invitedPeople count]==1){
            self.peopleLabel.text = [self.peopleLabel.text stringByAppendingString:[[@([self.invitedPeople count]) stringValue] stringByAppendingString: @" person"]];
        }else{
            self.peopleLabel.text = [self.peopleLabel.text stringByAppendingString:[[@([self.invitedPeople count]) stringValue] stringByAppendingString: @" people"]];
        }
    }
    
}

-(void)configureEventEditingView{
    self.selectorCell.tag = cellStateAlwaysOff;
    self.title = @"Edit Event";
    self.titleField.text = self.editableEvent.title;
    
    self.descriptionTextView.text = self.editableEvent.descrip;
    if(self.editableEvent.descrip){
        self.descriptionTextView.textColor = [UIColor blackColor];
    }
    if(self.editableEvent.imageURL){
        NSURL* url = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:self.editableEvent.imageURL]];
        [self.photo setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image-placeholder.png"]];
    }
    self.startTimePicker.date = self.editableEvent.start_date;
    self.endTimePicker.date = self.editableEvent.end_date;
    self.topRightBarButton.title = @"Save";
    
    self.startTimeLabel.text = [formatter stringFromDate:self.editableEvent.start_date];
    self.endTimeLabel.text = [formatter stringFromDate:self.editableEvent.end_date];

}

-(void)configureAnnouncementEditingView{
    self.topRightBarButton.title = @"Save";
    self.controlSwitch.selectedSegmentIndex = 1;
    self.selectorCell.tag = cellStateAlwaysOff;
    self.title = @"Edit Announcement";
    self.titleField.text = self.editableAnnouncement.title;
    self.descriptionTextView.text = self.editableAnnouncement.content;
    if(self.editableAnnouncement.content){
        self.descriptionTextView.textColor = [UIColor blackColor];
    }
    if(self.editableAnnouncement.imageURL){
        NSURL* url = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:self.editableAnnouncement.imageURL]];
        [self.photo setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image-placeholder.png"]];
    }

    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    //[self deregisterFromKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dateChanged:(id)sender{
    if(sender==self.startTimePicker){
        
        NSString *stringFromDate = [formatter stringFromDate:self.startTimePicker.date];
        self.startTimeLabel.text = stringFromDate;
        
        if([self.startTimePicker.date compare:self.endTimePicker.date]==NSOrderedDescending || [self.endTimeLabel.text isEqualToString:@"None"]){
            //if the start time is after the end time or the end time has not been set yet
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setHour:1];
        
            self.endTimePicker.date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.startTimePicker.date options:0];
        
            stringFromDate = [formatter stringFromDate:self.endTimePicker.date];
            self.endTimeLabel.text = stringFromDate;
        }else{
            //if the times are in the correct order, reset the end time label.
            //This is here in case the end time label has a strike through the time, it will reset if you change the start time to before the previously illegal end time
            stringFromDate = [formatter stringFromDate:self.endTimePicker.date];
            self.endTimeLabel.text = stringFromDate;
            
        }
    }else if(sender == self.endTimePicker){
        NSString* stringFromDate = [formatter stringFromDate:self.endTimePicker.date];
        
        if([self.endTimePicker.date compare:self.startTimePicker.date]==NSOrderedAscending){
            //if the end time if before the start time
            NSDictionary* attributes = @{
                                     NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                     };
        
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:stringFromDate attributes:attributes];
        
            self.endTimeLabel.attributedText = attrText;
        }else{
            //if the end time is after the start time
            self.endTimeLabel.text = stringFromDate;
        }
    }

}

#pragma mark table view delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger state = self.controlSwitch.selectedSegmentIndex;
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == state || cell.tag == cellStateAlwaysOn) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else {
        return 0;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.startTimeCell) {
        self.endPickerIsOpen = NO;
        self.startPickerIsOpen = !self.startPickerIsOpen;

    }
    else if (cell == self.endTimeCell) {
        self.startPickerIsOpen = NO;
        self.endPickerIsOpen = !self.endPickerIsOpen;

    }
    else {
        self.startPickerIsOpen = NO;
        self.endPickerIsOpen = NO;
    }
    
    [self updateDatePickers];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark image picker

- (void)onPhotoSelect
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Take a new photo", @"Choose from existing", nil];
    [actionSheet showInView:self.view];
}

- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
    }
}

-(void)choosePhotoFromExistingImages
{
    NSLog(@"choose a photo");
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    self.photo.image = image;

    NSLog(@"Post view frame height: %f", self.view.frame.size.height);
    
    // stores the image locally so that we can use the file path to send it to the server
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

# pragma mark state control

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    switch (buttonIndex) {
        case 0:
            [self takeNewPhotoFromCamera];
            break;
        case 1:
            [self choosePhotoFromExistingImages];
        default:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
    }
}

- (void)updateDatePickers
{
    if (self.startPickerIsOpen == NO) {
        self.startTimePickerCell.tag = cellStateAlwaysOff;

        // Update labels
        /*
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *stringFromDate = [formatter stringFromDate:self.startTimePicker.date];
        self.startTimeLabel.text = stringFromDate;*/
    }
    else {
        self.startTimePickerCell.tag = 0;
    }

    if (self.endPickerIsOpen == NO) {
        self.endTimePickerCell.tag = cellStateAlwaysOff;

        // Update labels
        /*
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *stringFromDate = [formatter stringFromDate:self.endTimePicker.date];
        self.endTimeLabel.text = stringFromDate;*/
    }
    else {
        self.endTimePickerCell.tag = 0;
    }
}

- (void)onControlSwitchChange
{
    self.startPickerIsOpen = NO;
    self.endPickerIsOpen = NO;
    [self updateDatePickers];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showInvites"]){
        NSLog(@"set the parent");
        PAInvitationsTableViewController* childController = [segue destinationViewController];
        childController.parentPostViewController = self;
        childController.invitedCircles = self.invitedCirclesDictionary;
        childController.invitedPeople = self.invitedPeopleDictionary;
    }
}

# pragma mark - text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
    [self.tableView scrollToRowAtIndexPath: indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==self.titleField){
        [self.descriptionTextView becomeFirstResponder];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionBottom animated:YES];
        return NO;
    }
    else if(textField==self.locationTextField){
        [self.locationTextField resignFirstResponder];
    }
    return YES;
}

# pragma mark - text view delegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.descriptionTextView.textColor == [UIColor lightGrayColor]) {
        self.descriptionTextView.text = @"";
        self.descriptionTextView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if([self.descriptionTextView.text isEqualToString:@""]){
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
        self.descriptionTextView.text = @"Description";
        
    }
}

- (IBAction)returnResultAndExit:(id)sender
{
    if([self.topRightBarButton.title isEqualToString:@"Save"]){
        //Editing
        if(_controlSwitch.selectedSegmentIndex==0){
            //The user is attempting to edit an event
            if([self.titleField.text isEqualToString:@""]){
                [self showAllertWithMessage:@"Your event must have a title"];
            }else{
                [self updateEvent];
            }
        }else{
            //the user is attemping to edit an announcement
            if([self.titleField.text isEqualToString:@""]){
                [self showAllertWithMessage:@"Your announcement must have a title"];
            }else{
                [self updateAnnouncement];
            }
        }
    }
    else{
        //Posting
        if(_controlSwitch.selectedSegmentIndex==0){
            //The user is attempting to post an event
            if([self.titleField.text isEqualToString:@""] || [self.startTimeLabel.text isEqualToString:@""]){
                [self showAllertWithMessage:@"You must enter an event name and time"];
            }else{
                [self postEvent];
            
            }
        }else if(_controlSwitch.selectedSegmentIndex==1){
            //The user is attempting to post an announcement
            if([self.titleField.text isEqualToString:@""]){
                [self showAllertWithMessage:@"You must enter an announcement title"];
            }else{
                [self postAnnouncement];
            }
        }
    }
}

-(void)showAllertWithMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)clearScreenAndDismissView{
    self.photo.image = [UIImage imageNamed:@"image-placeholder.png"];
    _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
    self.titleField.text=@"";
    self.descriptionTextView.text=@"";
    self.startTimeLabel.text =@"None";
    self.endTimeLabel.text = @"None";
    [self.tableView reloadData];
    
    
    // parent of self is a navigation controller, its parent is the dropdown controller
    [((PADropdownViewController*)self.parentViewController.parentViewController).dropdownBar deselectAllItems];
}

-(void)postEvent{
    
    NSData* data = UIImageJPEGRepresentation(self.photo.image, .5) ;
    
    [[PASyncManager globalSyncManager] postEvent: [self configureEventDictioanry] withImage:data];
    
    [self clearScreenAndDismissView];
}

-(void)postAnnouncement{
    
    NSData* data = UIImageJPEGRepresentation(self.photo.image, .5) ;
    
    [[PASyncManager globalSyncManager] postAnnouncement:[self configureAnnouncementDictionary] withImage:data];
    
    [self clearScreenAndDismissView];
}

-(void)updateEvent{
    NSData* data = nil;
    if(self.photo.image!=[UIImage imageNamed:@"image-placeholder.png"]){
        data = UIImageJPEGRepresentation(self.photo.image, .5) ;
    }
    
    [[PASyncManager globalSyncManager] updateEvent:self.editableEvent.id withDictionary:[self configureEventDictioanry] withImage:data];
    
    [self clearScreenAndDismissView];
    
}

-(void)updateAnnouncement{
    NSData* data = nil;
    
    if(self.photo.image!=[UIImage imageNamed:@"image-placeholder.png"]){
        NSLog(@"setting an image");
        data = UIImageJPEGRepresentation(self.photo.image, .5) ;
    }

    
    [[PASyncManager globalSyncManager] updateAnnouncement:self.editableAnnouncement.id withDictionary:[self configureAnnouncementDictionary] withImage:data];

    [self clearScreenAndDismissView];
    
}

-(NSDictionary*)configureEventDictioanry{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *instID = [defaults objectForKey:@"institution_id"];
    
    NSMutableArray* finalInvites = [self.invitedPeople mutableCopy];
    for( NSNumber* circleID in self.invitedCircles){
        Circle* circle = [[PAFetchManager sharedFetchManager] getObject:circleID withEntityType:@"Circle" andType:nil];
        NSSet*members = circle.circle_members;
        NSArray* circleMembers = [members allObjects];
        for(Peer* peer in circleMembers){
            if(![finalInvites containsObject:peer.id]){
                [finalInvites addObject:peer.id];
            }
        }
    }
    
    NSLog(@"final invites: %@", finalInvites);
    NSString* alert = [[defaults objectForKey:@"first_name"] stringByAppendingString:@" "];
    alert = [alert stringByAppendingString:[defaults objectForKey:@"last_name"]];
    alert = [alert stringByAppendingString:@" has invited you to an event"];
    
    NSDateFormatter* timeZoneFormatter = [[NSDateFormatter alloc] init];
    [timeZoneFormatter setDateFormat:@"MMM dd, yyyy h:mm a ZZZ"];
    NSString*startDate = [timeZoneFormatter stringFromDate:self.startTimePicker.date];
    NSString*endDate = [timeZoneFormatter stringFromDate:self.endTimePicker.date];
    
    NSLog(@"the start date: %@", startDate);
    NSString*description = @"";
    if(self.descriptionTextView.textColor != [UIColor lightGrayColor]){
        description = self.descriptionTextView.text;
    }
    
    NSDictionary *setEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.titleField.text,@"title",
                              description, @"event_description",
                              instID, @"institution_id",
                              startDate, @"start_date",
                              endDate, @"end_date",
                              [NSNumber numberWithBool:self.publicSwitch.on], @"public",
                              [defaults objectForKey:@"user_id"],@"invited_by",
                              [defaults objectForKey:@"user_id"], @"user_id",
                              finalInvites, @"event_member_ids",
                              alert,@"message",
                              [NSNumber numberWithBool:YES],@"send_push_notification",
                              nil];

    return setEvent;
}

-(NSDictionary*)configureAnnouncementDictionary{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *instID = [defaults objectForKey:@"institution_id"];
    
    NSString*description = @"";
    if(self.descriptionTextView.textColor != [UIColor lightGrayColor]){
        description = self.descriptionTextView.text;
    }

    
    NSDictionary* announcement = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.titleField.text,@"title",
                                  description, @"announcement_description",
                                  instID, @"institution_id",
                                  [defaults objectForKey:@"user_id"],@"user_id",
                                  nil];
    return announcement;
}


@end
