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
            
            [self selectCurrentDefaultIfExists];
        }
    }];
    
    [self selectCurrentDefaultIfExists];
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

- (void)selectCurrentDefaultIfExists
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * instId = [defaults objectForKey:@"institution_id"];
    if (instId != nil) {
        // selects currently chosen institution
        [schoolPicker selectRow:[self indexForInstitutionId:instId.integerValue] inComponent:0 animated:NO];
    }
}

- (NSInteger)indexForInstitutionId:(NSInteger)instId
{
    int len = (int)self.institutions.count;
    for (int pos = 0; pos < len; pos++) {
        Institution * inst = (Institution*)self.institutions[pos];
        if (inst.id.integerValue == instId) {
            return pos;
        }
    }
    return 0;
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
    // sets the default if they never scroll the pickerview
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"institution_id"] == nil) {
        [defaults setObject:[NSNumber numberWithInt:1] forKey:@"institution_id"];
    }
    
    PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // if this is root because of the initial download of the app
    if ([appDelegate window].rootViewController == self) {
        UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
        
        [appDelegate.window setRootViewController:newRoot];
    } else {
    
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
