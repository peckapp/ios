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
#import "Message.h"
#import "PADropdownViewController.h"
#import "PAPeers.h"
#import "PAImageManager.h"
#import "PASessionManager.h"
#import "PASyncManager.h"
#import "PAInvitationsTableViewController.h"

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

    [self.photoButton addTarget:self action:@selector(onPhotoSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.controlSwitch addTarget:self action:@selector(onControlSwitchChange) forControlEvents:UIControlEventValueChanged];
    
    self.locationTextField.delegate = self;
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    _initialTableViewFrame = self.tableView.frame;
}

-(void)viewWillAppear:(BOOL)animated{
    [self registerForKeyboardNotifications];
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
-(void)viewWillDisappear:(BOOL)animated{
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
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if(CGRectEqualToRect(_initialTableViewFrame, self.tableView.frame)){
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-keyboardSize.height);
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    self.tableView.frame = _initialTableViewFrame;
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
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    self.photoButton.imageView.image = image;
    
    // stores the image locally so that we can use the file path to send it to the server
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated: YES completion: nil];
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *stringFromDate = [formatter stringFromDate:self.startTimePicker.date];
        self.startTimeLabel.text = stringFromDate;
    }
    else {
        self.startTimePickerCell.tag = 0;
    }

    if (self.endPickerIsOpen == NO) {
        self.endTimePickerCell.tag = cellStateAlwaysOff;

        // Update labels
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *stringFromDate = [formatter stringFromDate:self.endTimePicker.date];
        self.endTimeLabel.text = stringFromDate;
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

- (IBAction)cancelResultAndExit:(id)sender
{

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



- (IBAction)returnResultAndExit:(id)sender
{
    if(_controlSwitch.selectedSegmentIndex==0){
        if([self.titleField.text isEqualToString:@""] || [self.startTimeLabel.text isEqualToString:@""]){
            NSLog(@"alllert");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                            message:@"You must enter an event name and time"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        
        } else {
            //[[PAImageManager imageManager] WriteImage:imageData WithTitle:event.title];
            //[event setId:_userEvents[0]];
            
            NSNumber *instID = [[NSUserDefaults standardUserDefaults] objectForKey:@"institution_id"];
            
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:
                              @"event_photo.png" ];
            NSData* data = UIImageJPEGRepresentation(self.photoButton.imageView.image, .5) ;
            [data writeToFile:path atomically:YES];
            //NSLog(@"path: %@", path);
            
            NSDictionary *setEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                      self.titleField.text,@"title",
                                      self.descriptionField.text, @"event_description",
                                      instID, @"institution_id",
                                      self.startTimeLabel.text, @"start_date",
                                      self.endTimeLabel.text, @"end_date",
                                      nil];
            
            [[PASyncManager globalSyncManager] postEvent: setEvent withImage:data];
            
            
            
            
            self.photoButton.imageView.image = [UIImage imageNamed:@"image-placeholder.png"];
            _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
            [self.tableView reloadData];
            
            
            //[self performSegueWithIdentifier:@"showEvents" sender:self];
            
            // parent of self is a navigation controller, its parent is the dropdown controller
            [((PADropdownViewController*)self.parentViewController.parentViewController).dropdownBar deselectAllItems];
        }
        
    }
    /*
    else if(_controlSwitch.selectedSegmentIndex==1){
        if([_userEvents[1] isEqualToString:@""]){
            NSLog(@"allert");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                            message:@"You must enter a message"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
            PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
            _managedObjectContext = [appdelegate managedObjectContext];
            
            Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:_managedObjectContext];
            [message setText:_userEvents[1]];
            [message setCreated_at:[NSDate date]];
            [message setId:_userEvents[1]];
            // NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(photo)];
            // [message setPhoto:imageData];
            
            
            //  photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
            _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
            [self.tableView reloadData];
            //[self performSegueWithIdentifier:@"showFeed" sender:self];
            
        }
    }
}

*/
    
    
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
 if (self.controlSwitch.selectedSegmentIndex == 0) {
 cell = self.cellIWantToShow;
 }
 return cell;
 }

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
 if (indexPath.section == 0 && hideStuff) {
 height = [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
 }
 return height;
 }

 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 NSInteger count = [super tableView:tableView numberOfRowsInSection:section];

 if (section == 0 && hideStuff) {
 count -= hiddenCells.count;
 }

 return count;
 }
 */

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

 UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell"];
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
 cell.accessoryType = UITableViewCellAccessoryNone;
 if ([indexPath section] == 0) {

 UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(140, 8, 185, 30)];

 playerTextField.adjustsFontSizeToFitWidth = YES;
 playerTextField.textColor = [UIColor blackColor];
 playerTextField.keyboardType = UIKeyboardTypeDefault;
 playerTextField.returnKeyType = UIReturnKeyDone;
 playerTextField.backgroundColor = [UIColor whiteColor];
 playerTextField.autocorrectionType = UITextAutocorrectionTypeYes; // auto correction support
 playerTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences; // auto capitalization support
 [playerTextField setEnabled: YES];
 playerTextField.delegate = self;

 [cell.contentView addSubview:playerTextField];

 UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x + 15, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
 //titleLabel.text =[eventItems objectAtIndex:[indexPath row]];
 [cell.contentView addSubview:titleLabel];

 UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 0, 50, 44)];
 imageView.image = photo;
 [cell.contentView addSubview:imageView];

 }
 }

 if ([indexPath section] == 0) {
 cell.tag=[indexPath row];
 UIImageView *imageView = (UIImageView *) cell.contentView.subviews[2];
 imageView.frame = CGRectMake(140, 0, 60, 44);
 imageView.tag = [indexPath row];
 if([indexPath row] != 1 || _controlSwitch.selectedSegmentIndex==1){
 imageView.image=nil;
 }
 UITextField * textField = (UITextField*) cell.contentView.subviews[0];
 textField.hidden=NO;
 [textField setUserInteractionEnabled:YES];
 textField.placeholder = [_eventSuggestions objectAtIndex:[indexPath row]];
 textField.text = [_userEvents objectAtIndex:[indexPath row]];
 textField.tag = [indexPath row];
 UILabel * title = (UILabel*) cell.contentView.subviews[1];
 title.text = [_eventItems objectAtIndex:[indexPath row]];
 if((_controlSwitch.selectedSegmentIndex==1 && [indexPath row]==2) || (_controlSwitch.selectedSegmentIndex==0 && [indexPath row]==1))//these are the locations of both of the "add a photo cells"
 {
 textField.hidden=YES;
 imageView.image = photo;
 if(_controlSwitch.selectedSegmentIndex==1){
 imageView.frame = CGRectMake(120, 0, 140, 100);
 }
 }
 if(_controlSwitch.selectedSegmentIndex==0)//Events
 {
 textField.frame = CGRectMake(140, 8, 185, 30);
 if([indexPath row]==3){
 //the date field
 [textField setUserInteractionEnabled:NO];
 }
 }
 if(_controlSwitch.selectedSegmentIndex==1)//Messages
 {
 textField.frame = CGRectMake(15, 45, 250, 30);
 }
 }
 return cell;
 }
 */


/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(([indexPath row]==1 && _controlSwitch.selectedSegmentIndex==0) || ([indexPath row]==2 && _controlSwitch.selectedSegmentIndex==1)){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                 delegate: self
                                                        cancelButtonTitle: @"Cancel"
                                                   destructiveButtonTitle: nil
                                                        otherButtonTitles: @"Take a new photo", @"Choose from existing", nil];
        [actionSheet showInView:self.view];
        NSLog(@"add a photo");
    }
    else if([indexPath row]==3 && _controlSwitch.selectedSegmentIndex==0){
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Done",nil];
        
        // Add the picker
        UIDatePicker *pickerView = [[UIDatePicker alloc] init];
        
        CGRect pickerRect = pickerView.bounds;
        pickerRect.origin.y = -40;
        pickerView.bounds = pickerRect;
        [menu addSubview:pickerView];
        [menu showInView:self.view];
        [menu setBounds:CGRectMake(0, 0, 320, 450)];
        [pickerView addTarget:self action:@selector(pickerChanged:)forControlEvents:UIControlEventValueChanged];
        

           }
    else{
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
*/

/*
- (void)pickerChanged:(id)sender
{
    chosenDate = [sender date];
}

# pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, initialTVHeight);
    NSLog(@"new frame height: %f", self.tableView.frame.size.height-216);
    if(self.tableView.frame.size.height==initialTVHeight){
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-(216+22));
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideKeyboard];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"didEndEditing");
    [self updateEventArray];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateEventArray];
}

-(void)updateEventArray{

    
    int count=0;
    if(_controlSwitch.selectedSegmentIndex==0){
        count=6;
    }
    if(_controlSwitch.selectedSegmentIndex==1){
        count=2;
    }
    for(int i=0; i<count; i++){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField * textField = (UITextField*) cell.contentView.subviews[0];
        NSString * text =textField.text;
        if(text!=nil)
            _userEvents[i]=text;
    }
   
}

- (IBAction)segmentedControl:(id)sender {
    // photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
    self.userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
    //self.tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, initialTVHeight);
    // Necessary in case the keyboard is up while switching the segmented control
    if(_controlSwitch.selectedSegmentIndex==0){
//        _tableView.rowHeight = initialRowHeight;
//        self.detailKeys=@[@"Event Name", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
//        self.detailValues=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
    }
    else if(_controlSwitch.selectedSegmentIndex==1){
//        _tableView.rowHeight=100;
//        self.detailKeys=@[@"Who are you sharing with?", @"What's on your mind?",@"Add a photo"];
//        =@[@"Mom, Dad",@"My message",@""];
    }
    [self.tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(([indexPath row]==1 && _controlSwitch.selectedSegmentIndex==0) || ([indexPath row]==2 &&_controlSwitch.selectedSegmentIndex==1)){
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
    }else if([indexPath row]==3 && _controlSwitch.selectedSegmentIndex==0){
        switch (buttonIndex) {
            case 0:
                [self addDate];
                break;
            default:
                break;
        }
    }
}

-(void)addDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
    NSString *stringFromDate = [formatter stringFromDate:chosenDate];
    _userEvents[3]=stringFromDate;
    [self.tableView reloadData];
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
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
        
    }
}
# pragma mark - image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated: YES completion: nil];
    //UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    // photo = image;
    //UIImageView * imageView = (UIImageView *)[self.view viewWithTag:6];
    //imageView.image =photo;
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated: YES completion: nil];
}




- (IBAction)okayButton:(id)sender {
    if(_controlSwitch.selectedSegmentIndex==0){
        if([_userEvents[0] isEqualToString:@""] || [_userEvents[3] isEqualToString:@""]){
            NSLog(@"allert");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                            message:@"You must enter an event name and time"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
            PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
            _managedObjectContext = [appdelegate managedObjectContext];
    
            Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
            [event setTitle:_userEvents[0]];
            [event setLocation:_userEvents[2]];
            [event setStart_date:chosenDate];
            [event setDescrip:_userEvents[5]];
            [event setCreated_at:[NSDate date]];
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(photo)];
            
            
           
            
            [[PAImageManager imageManager] WriteImage:imageData WithTitle:event.title];
            //also set the image title to the id rather than the title
            
            
            
            //[event setId:_userEvents[0]];
           
            
            
            NSDictionary *setEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                                     _userEvents[0],@"title",
                                    _userEvents[5], @"event_description",
                                      [NSNumber numberWithInt:1], @"institution_id",
                                     _userEvents[5], @"event_description",
                                      _userEvents[3], @"start_date",
                                      _userEvents[3], @"end_date",
                                      nil];
            
            [[PASyncManager globalSyncManager] postEvent: setEvent];
            
            
            
            
            photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
            _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
            [self.tableView reloadData];
    

            //[self performSegueWithIdentifier:@"showEvents" sender:self];
        }
        
    }
    else if(_controlSwitch.selectedSegmentIndex==1){
        if([_userEvents[1] isEqualToString:@""]){
            NSLog(@"allert");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                            message:@"You must enter a message"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
            PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
            _managedObjectContext = [appdelegate managedObjectContext];
            
            Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:_managedObjectContext];
            [message setText:_userEvents[1]];
            [message setCreated_at:[NSDate date]];
            [message setId:_userEvents[1]];
            // NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(photo)];
            // [message setPhoto:imageData];

            
            //  photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
            _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
            [self.tableView reloadData];
            //[self performSegueWithIdentifier:@"showFeed" sender:self];

        }
    }
}
*/

@end
