//
//  ConfigureViewController.m
//  Peck
//
//  Created by John Karabinos on 6/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "ConfigureViewController.h"
#import "PADiningTableViewController.h"

@interface ConfigureViewController ()

@end

@implementation ConfigureViewController
@synthesize schoolPicker;
@synthesize schools;

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
       // Do any additional setup after loading the view.
    schools = [[NSArray alloc] initWithObjects:@"Williams",@"Middlebury", nil];
    schoolPicker.dataSource = self;
    schoolPicker.delegate = self;
    
    [schoolPicker reloadAllComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 2;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"schools" ofType:@"plist"];
    NSArray *colleges = [[NSArray alloc] initWithContentsOfFile:path];
    return [colleges objectAtIndex:row];
}


- (IBAction)continueButton:(id)sender {
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UITabBarController *tabController;
    tabController = segue.destinationViewController;
    NSLog(@"%@",tabController.viewControllers);
    for (UINavigationController* navController in tabController.viewControllers) {
        UIViewController <PACoreDataProtocol> * viewController = (UIViewController <PACoreDataProtocol> *)navController.topViewController;
        viewController.managedObjectContext = self.managedObjectContext;
    }
    

}

@end
