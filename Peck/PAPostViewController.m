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
@interface PAPostViewController () {
    NSMutableArray * userEvents;
}

@end

@implementation PAPostViewController

//@synthesize tableView = _tableView;
@synthesize eventItems = _eventItems;
@synthesize eventSuggestions = _eventSuggestions;
@synthesize controlSwitch = _controlSwitch;
@synthesize photo;
@synthesize userEvents = _userEvents;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

int initialTVHeight;
int initialRowHeight;
int titleThickness;
NSDate *chosenDate;
UITableView *_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PAPeers *peerTree1 = [PAPeers peers];
    NSString *name1 = peerTree1.peerTree.right.name;
    NSLog(@"peerTree1 name1: %@", name1);
    NSMutableArray *names = [NSMutableArray array];
    names = [peerTree1.peerTree searchForName:@"J" WithArray:names];
    NSLog(@"Names: %@", names);
    BOOL nameExists = [peerTree1.peerTree search:@"Andrew"];
    NSLog(@"andrew exists? %u", nameExists);
    
    
    
    
    chosenDate= [NSDate date];
    if(!_tableView){
        titleThickness=88;
        int topOffSet = titleThickness;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleThickness, self.view.frame.size.width, self.view.frame.size.height-topOffSet)];
        NSLog(@"table view height: %f", self.view.frame.size.height-topOffSet);
        [self.view addSubview:_tableView];
    }
    _tableView.delegate=self;
    _tableView.dataSource=self;
    //_tableView.frame = CGRectMake(_tableView.frame.origin.x, 300, _tableView.frame.size.width, _tableView.frame.size.height);
    initialTVHeight = _tableView.frame.size.height;
    initialRowHeight = _tableView.rowHeight;
    photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
    _eventItems=@[@"Event Name", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
    _eventSuggestions=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
    
    //[_userEvents initWithArray:@[@"",@"",@"",@"",@"",@""]];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView=NO;
    [_tableView addGestureRecognizer:gestureRecognizer];
    // This code allows the user to dismiss the keyboard by pressing somewhere else
    
    _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) hideKeyboard{
     _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, initialTVHeight);
    [self.view endEditing:NO];
    }

# pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _eventItems.count;
}

#pragma mark - table view delegate

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
            
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x+15, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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

- (void)pickerChanged:(id)sender
{
    chosenDate = [sender date];
}

# pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, initialTVHeight);
    NSLog(@"new frame height: %f", _tableView.frame.size.height-216);
    if(_tableView.frame.size.height==initialTVHeight){
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height-(216+22));
    // TODO: the keyboard height reads 216 but should not be hardcoded
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField * textField = (UITextField*) cell.contentView.subviews[0];
        NSString * text =textField.text;
        if(text!=nil)
            _userEvents[i]=text;
    }
   
}


- (IBAction)segmentedControl:(id)sender {
    photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
    _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
   _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, initialTVHeight);
    // Necessary in case the keyboard is up while switching the segmented control
    if(_controlSwitch.selectedSegmentIndex==0){
        _tableView.rowHeight = initialRowHeight;
        _eventItems=@[@"Event Name", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
        _eventSuggestions=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
    }
    else if(_controlSwitch.selectedSegmentIndex==1){
        _tableView.rowHeight=100;
        _eventItems=@[@"Who are you sharing with?", @"What's on your mind?",@"Add a photo"];
        _eventSuggestions=@[@"Mom, Dad",@"My message",@""];
    }
    [_tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if(([indexPath row]==1 && _controlSwitch.selectedSegmentIndex==0) || ([indexPath row]==2 &&_controlSwitch.selectedSegmentIndex==1)){
        switch (buttonIndex) {
            case 0:
                [self takeNewPhotoFromCamera];
                break;
            case 1:
                [self choosePhotoFromExistingImages];
            default:
                [_tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [_tableView reloadData];
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
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    photo = image;
    UIImageView * imageView = (UIImageView *)[self.view viewWithTag:6];
    imageView.image =photo;
    [_tableView reloadData];
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
            [event setPhoto:imageData];
            //TODO: Set the id to something other than the title
            [event setId:_userEvents[0]];
            photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
            _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
            [_tableView reloadData];
    
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
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(photo)];
            [message setPhoto:imageData];

            
            photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
            _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
            [_tableView reloadData];
            //[self performSegueWithIdentifier:@"showFeed" sender:self];

        }
    }
}

@end
