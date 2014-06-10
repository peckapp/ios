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
    
    eventItems=@[@"Event Names", @"Add a Photo", @"Location", @"Date and Time", @"Who's Invited", @"Description"];
    eventSuggestions=@[@"My Birthday!",@"",@"Mount Everest",@"January 1, 2015", @"Mom, Dad", @"BYOB"];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    // This code allows the user to dismiss the keyboard by pressing somewhere else
    
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    return 6;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([indexPath section] == 0) {
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(140, 10, 185, 30)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            playerTextField.textColor = [UIColor blackColor];
            playerTextField.placeholder = [eventSuggestions objectAtIndex:[indexPath row]];
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyDone;
            playerTextField.backgroundColor = [UIColor whiteColor];
            playerTextField.autocorrectionType = UITextAutocorrectionTypeYes; // auto correction support
            playerTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences; // auto capitalization support
            playerTextField.tag = 0;
            //playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [playerTextField setEnabled: YES];
            playerTextField.delegate = self;
            
            [cell addSubview:playerTextField];
            
            
                   }
    }
    if ([indexPath section] == 0) { // Email & Password Section
        cell.textLabel.text = [eventItems objectAtIndex:[indexPath row]];
    }
    
    return cell;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}


- (IBAction)cancelButton:(id)sender {
   [self dismissViewControllerAnimated:YES completion:^(void){}];
}
@end
