//
//  PACreateCircleViewController.m
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACreateCircleViewController.h"
#import "PAAppDelegate.h"
#import "Circle.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"

@interface PACreateCircleViewController ()

@end

@implementation PACreateCircleViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize titleTextField, membersAutocompleteTextField;
@synthesize titleLabel;


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
    [titleTextField addTarget:self
                  action:@selector(textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    
    membersAutocompleteTextField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    membersAutocompleteTextField.autocompleteType = HTAutocompleteTypeName;
    
    //[self.view addSubview:testField];
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 44)];
    //bar.barStyle= UIBarStyleBlackTranslucent;
    //bar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(chooseMember)];
    NSArray * buttons = [[NSArray alloc] initWithObjects:button, nil];
    
    [bar setItems:buttons];
    membersAutocompleteTextField.inputAccessoryView = bar;
    // Do any additional setup after loading the view.
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

-(void)chooseMember{
    NSLog(@"choose a member");
    NSString *tempText= membersAutocompleteTextField.text;
    tempText = [tempText stringByAppendingString:membersAutocompleteTextField.autocompleteLabel.text];
    membersAutocompleteTextField.text = [tempText stringByAppendingString:@", "];
    
}

-(void)textFieldDidChange{
    titleLabel.text = titleTextField.text;

}

- (IBAction)createCircleButton:(id)sender {
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    Circle * circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext: _managedObjectContext];
    
    [circle setCircleName:titleTextField.text];
    NSString *membersString= membersAutocompleteTextField.text;
    NSArray *membersArray = [membersString componentsSeparatedByString:@","];
    [circle setMembers:membersArray];
    
}
@end
