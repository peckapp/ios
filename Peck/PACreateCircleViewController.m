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


@interface PACreateCircleViewController ()

@end

@implementation PACreateCircleViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize titleTextField, membersTextField;


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
    UIBarButtonItem *button = [[UIBarButtonItem alloc] init];
    NSArray * buttons = @[button];
    UIToolbar *bar = [[UIToolbar alloc] init];
    [bar setItems:buttons];
    membersTextField.inputAccessoryView = bar;
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

- (IBAction)createCircleButton:(id)sender {
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    Circle * circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext: _managedObjectContext];
    
    [circle setCircleName:titleTextField.text];
    NSString *membersString= membersTextField.text;
    NSArray *membersArray = [membersString componentsSeparatedByString:@","];
    [circle setMembers:membersArray];
    
}
@end
