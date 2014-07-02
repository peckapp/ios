//
//  ConfigureViewController.m
//  Peck
//
//  Created by John Karabinos on 6/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAConfigureViewController.h"

#import "PAAppDelegate.h"
#import "PADropdownViewController.h"

#import "PASyncManager.h"
#import "Institution.h"

@interface PAConfigureViewController ()

@property (nonatomic,retain) NSArray * institutions;

@end

@implementation PAConfigureViewController
@synthesize schoolPicker;

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
    
    PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appDelegate managedObjectContext];
    
    schoolPicker.dataSource = self;
    schoolPicker.delegate = self;
    
    [schoolPicker reloadAllComponents];
    
    [[PASyncManager globalSyncManager] updateAvailableInstitutionsWithCallback:^(BOOL success) {
        if (success) {
            NSLog(@"executing callback for institution configurator");
            self.institutions = [self fetchInstitutions];
            [self.schoolPicker reloadAllComponents];
        }
    }];
    
    // sets the default if they never scroll the pickerview
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"institution_id"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)fetchInstitutions
{
    NSManagedObjectContext *moc = _managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Institution" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    return array;
}

#pragma mark - Navigation

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // the number of institutions in the current array
    return self.institutions.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Institution * institution = (Institution*)[self.institutions objectAtIndex:row];
    return institution.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    Institution * institution = (Institution*)[self.institutions objectAtIndex:row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:institution.id forKey:@"institution_id"];
    NSLog(@"selected institution: %@ with id: %@",institution.name,institution.id);
}


- (IBAction)continueButton:(id)sender
{
    PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
    
    [appDelegate.window setRootViewController:newRoot];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    PADropdownViewController *dropdownController = (PADropdownViewController*)segue.destinationViewController;
    
    NSLog(@"%@",dropdownController.secondaryViewControllers);
    
    /*
    for (UINavigationController* navController in dropdownController.secondaryViewControllers) {
        UIViewController <PACoreDataProtocol> * viewController = (UIViewController <PACoreDataProtocol> *)navController.topViewController;
        viewController.managedObjectContext = self.managedObjectContext;
    }
    */

}

@end
