//
//  PAPostViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPostViewController.h"

@interface PAPostViewController ()

@end

@implementation PAPostViewController
@synthesize tableView;
@synthesize eventItems;
@synthesize eventSuggestions;
@synthesize controlSwitch;
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
    tableView.delegate=self;
    tableView.dataSource=self;
    initialTVHeight = tableView.frame.size.height;
    initialRowHeight = tableView.rowHeight;
    
    
    eventItems=@[@"Event Name", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
    eventSuggestions=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    // This code allows the user to dismiss the keyboard by pressing somewhere else
    
    
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
     self.tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, initialTVHeight);
    [self.view endEditing:NO];;
    }

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return eventItems.count;
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
        }

    }
    
    
    
    if ([indexPath section] == 0) {
        
        UITextField * textField = (UITextField*) cell.contentView.subviews[0];
        textField.hidden=NO;
        textField.placeholder = [eventSuggestions objectAtIndex:[indexPath row]];
        textField.tag = [indexPath row];
        
        UILabel * title = (UILabel*) cell.contentView.subviews[1];
        title.text = [eventItems objectAtIndex:[indexPath row]];
        if((controlSwitch.selectedSegmentIndex==2 && [indexPath row]==1) || (controlSwitch.selectedSegmentIndex==0 && [indexPath row]==1)){
            textField.hidden=YES;
        }

        if(controlSwitch.selectedSegmentIndex==0){
            textField.frame = CGRectMake(140, 8, 185, 30);
        }
        if(controlSwitch.selectedSegmentIndex==1 || controlSwitch.selectedSegmentIndex==2){
                        textField.frame = CGRectMake(15, 45, 250, 30);
        }
       
        //cell.textLabel.text = [eventItems objectAtIndex:[indexPath row]];
        
    }
    
    return cell;    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    self.tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 115);
    // TODO: the height reads 115 but should be changed to reflect
    NSLog(@"%f",tableView.frame.size.height);
    NSLog(@"%f",tableView.frame.origin.y);
   
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, initialTVHeight);
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)cancelButton:(id)sender {
   [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction)segmentedControl:(id)sender {
    if(controlSwitch.selectedSegmentIndex==0){
        tableView.rowHeight = initialRowHeight;
        self.tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, initialTVHeight);
        // Necessary in case the keyboard is up while switching the segmented control
        eventItems=@[@"Event Name", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
        eventSuggestions=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
        [self.tableView reloadData];
    }
    else if(controlSwitch.selectedSegmentIndex==1){
        tableView.rowHeight=100;
        self.tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, initialTVHeight);
        // Necessary in case the keyboard is up while switching the segmented control
        eventItems=@[@"Who are you sharing with?", @"What's on your mind?"];
        eventSuggestions=@[@"",@""];
        [self.tableView reloadData];
    }else if(controlSwitch.selectedSegmentIndex==2){
        tableView.rowHeight=100;
        self.tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, initialTVHeight);
        // Necessary in case the keyboard is up while switching the segmented control
        eventItems=@[@"Who are you sharing with?",@"",@"Comment"];
        eventSuggestions=@[@"",@"",@""];
        [self.tableView reloadData];
    }
}
@end
