//
//  PAPostViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPostViewController.h"

@interface PAPostViewController () {
    NSMutableArray * userEvents;
}

@end

@implementation PAPostViewController

@synthesize tableView = _tableView;
@synthesize eventItems = _eventItems;
@synthesize eventSuggestions = _eventSuggestions;
@synthesize controlSwitch = _controlSwitch;
@synthesize photo;
@synthesize userEvents = _userEvents;


int initialTVHeight;
int initialRowHeight;

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
    _tableView.delegate=self;
    _tableView.dataSource=self;
    initialTVHeight = _tableView.frame.size.height;
    initialRowHeight = _tableView.rowHeight;
    photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
    _eventItems=@[@"Event Name", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
    _eventSuggestions=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
    
    //[_userEvents initWithArray:@[@"",@"",@"",@"",@"",@""]];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView=NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
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
     self.tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, initialTVHeight);
    [self.view endEditing:NO];
    }

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
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
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 0, 60, 44)];
            imageView.image = photo;
            [cell.contentView addSubview:imageView];
            
        }
    }
    
    if ([indexPath section] == 0) {
        UIImageView *imageView = (UIImageView *) cell.contentView.subviews[2];
        imageView.frame = CGRectMake(140, 0, 60, 44);
        if([indexPath row] != 1 || _controlSwitch.selectedSegmentIndex==1){
            imageView.image=nil;
        }
        UITextField * textField = (UITextField*) cell.contentView.subviews[0];
        textField.hidden=NO;
        textField.placeholder = [_eventSuggestions objectAtIndex:[indexPath row]];
        textField.text = [_userEvents objectAtIndex:[indexPath row]];
        textField.tag = [indexPath row];
        UILabel * title = (UILabel*) cell.contentView.subviews[1];
        title.text = [_eventItems objectAtIndex:[indexPath row]];
        if((_controlSwitch.selectedSegmentIndex==2 && [indexPath row]==1) || (_controlSwitch.selectedSegmentIndex==0 && [indexPath row]==1))//these are the locations of both of the "add a photo cells"
        {
            textField.hidden=YES;
            imageView.image = photo;
            if(_controlSwitch.selectedSegmentIndex==2){
                imageView.frame = CGRectMake(80, 0, 150, 100);
            }
        }
        if(_controlSwitch.selectedSegmentIndex==0)//Events
        {
            textField.frame = CGRectMake(140, 8, 185, 30);
        }
        if(_controlSwitch.selectedSegmentIndex==1 || _controlSwitch.selectedSegmentIndex==2)//Messages and Photos
        {
            textField.frame = CGRectMake(15, 45, 250, 30);
        }
    }
    //if([indexPath row]==0 || [indexPath row]==6)
    //[self updateEventArray];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(([indexPath row]==1 && _controlSwitch.selectedSegmentIndex==0) || ([indexPath row]==1 && _controlSwitch.selectedSegmentIndex==2)){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                                 delegate: self
                                                        cancelButtonTitle: @"Cancel"
                                                   destructiveButtonTitle: nil
                                                        otherButtonTitles: @"Take a new photo", @"Choose from existing", nil];
        [actionSheet showInView:self.view];
        NSLog(@"add a photo");
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    self.tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, 115);
    // TODO: the height reads 115 but should be changed to reflect the heigh of the keyboard
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    if(_controlSwitch.selectedSegmentIndex==2){
        count=3;
    }
    for(int i=0; i<count; i++){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField * textField = (UITextField*) cell.contentView.subviews[0];
        NSString * text =textField.text;
        if(text!=nil)
            _userEvents[i]=text;
         NSLog(@"%@", _userEvents);
    }
   
}


- (IBAction)cancelButton:(id)sender {
   [self dismissViewControllerAnimated:YES completion:^(void){}];
}


- (IBAction)segmentedControl:(id)sender {
    photo = [UIImage imageNamed:@"ImagePlaceholder.jpeg"];
    _userEvents = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
   self.tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, initialTVHeight);
    // Necessary in case the keyboard is up while switching the segmented control
    if(_controlSwitch.selectedSegmentIndex==0){
        _tableView.rowHeight = initialRowHeight;
        _eventItems=@[@"Event Name", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
        _eventSuggestions=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
    }
    else if(_controlSwitch.selectedSegmentIndex==1){
        _tableView.rowHeight=100;
        _eventItems=@[@"Who are you sharing with?", @"What's on your mind?"];
        _eventSuggestions=@[@"",@""];
    }else if(_controlSwitch.selectedSegmentIndex==2){
        _tableView.rowHeight=100;
        _eventItems=@[@"Who are you sharing with?",@"",@"Comment"];
        _eventSuggestions=@[@"",@"",@""];
    }
    [self.tableView reloadData];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self takeNewPhotoFromCamera];
            break;
        case 1:
            [self choosePhotoFromExistingImages];
        default:
            break;
    }
}
- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        //controller.allowsEditing = NO;
        //controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        controller.delegate = self;
        [self presentViewController: controller animated: YES completion: nil];
    }
}
-(void)choosePhotoFromExistingImages
{
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
    NSLog(@"picked photo");
    [self dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    photo = image;
    UIImageView * imageView = (UIImageView *)[self.view viewWithTag:6];
    imageView.image =photo;
    //UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    //[self.view addSubview: imageView];
    [self.tableView reloadData];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated: YES completion: nil];
}
@end
