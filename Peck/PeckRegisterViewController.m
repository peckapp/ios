//
//  PeckRegisterViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/15/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PeckRegisterViewController.h"

@interface PeckRegisterViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITableView *inputTable;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;


@end


@implementation PeckRegisterViewController

@synthesize registerItems = _registerItems;
@synthesize userRegistrationItems = _userRegistrationItems;
int initialTVHeight;


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
    _registerItems = @[@"Name",@"Email",@"Password",@"Twitter",@"Phone #",@"Blurb"];
    _inputTable.delegate = self;
    _inputTable.dataSource = self;
    initialTVHeight = _inputTable.frame.size.height;
    _userRegistrationItems = [NSMutableArray arrayWithArray:@[@"",@"",@"",@"",@"",@""]];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard{
    self.inputTable.frame = CGRectMake(_inputTable.frame.origin.x, _inputTable.frame.origin.y, _inputTable.frame.size.width, initialTVHeight);
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
    return _registerItems.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.inputTable dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([indexPath section] == 0) {
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(120, 7, 175, 30)];
            
            playerTextField.adjustsFontSizeToFitWidth = YES;
            playerTextField.textColor = [UIColor blackColor];
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyDone;
            playerTextField.backgroundColor = [UIColor whiteColor];
            playerTextField.borderStyle = UITextBorderStyleRoundedRect;
            playerTextField.autocorrectionType = UITextAutocorrectionTypeYes; // auto correction support
            playerTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences; // auto capitalization support
            
            [playerTextField setEnabled: YES];
            playerTextField.delegate = self;
            
            [cell.contentView addSubview:playerTextField];
            
            UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.origin.x+15, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
            [cell.contentView addSubview:titleLabel];
            
        }
    }
    
    if ([indexPath section] == 0) {
        UITextField * textField = (UITextField*) cell.contentView.subviews[0];
        textField.text = [_userRegistrationItems objectAtIndex:[indexPath row]];
        UILabel * title = (UILabel*) cell.contentView.subviews[1];
        title.text = [_registerItems objectAtIndex:[indexPath row]];
       
    }
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    self.inputTable.frame = CGRectMake(_inputTable.frame.origin.x, _inputTable.frame.origin.y, _inputTable.frame.size.width, 115);
    // TODO: the height reads 115 but should be changed to reflect the heigh of the keyboard
    [self.inputTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    for(int i=0; i<6; i++){
        UITableViewCell *cell = [self.inputTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField * textField = (UITextField*) cell.contentView.subviews[0];
        NSString * text =textField.text;
        if(text!=nil)
            _userRegistrationItems[i]=text;
    }
    
}

@end
