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

#import "PAFetchManager.h"

@interface PAConfigureViewController ()

@property (nonatomic,retain) NSArray * institutions;

@end

@implementation PAConfigureViewController
@synthesize schoolPicker;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;

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
    
    NSArray* institutions = [self fetchInstitutions];
    if([institutions count]>0){
        self.institutions = institutions;
    }
    
    [self updateInstitutions];
    
    [schoolPicker reloadAllComponents];
    
    
    [self selectCurrentDefaultIfExists];
}

-(void)updateInstitutions{
    [[PASyncManager globalSyncManager] updateAvailableInstitutionsWithCallback:^(BOOL success) {
        if (success) {
            NSLog(@"executing callback for institution configurator");
            self.institutions = [self fetchInstitutions];
            [self.schoolPicker reloadAllComponents];
            
            [self selectCurrentDefaultIfExists];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)fetchInstitutions
{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Institution" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
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

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component  reusingView:(UIView *)view
{
    Institution * institution = (Institution*)[self.institutions objectAtIndex:row];
    
    UILabel * institutionLabel = [[UILabel alloc] init];
    //institutionLabel.frame = CGRectMake(0, 0, 90, 20);
    institutionLabel.font = [UIFont systemFontOfSize:30];
    institutionLabel.text = institution.name;
    institutionLabel.textColor = [UIColor whiteColor];
    institutionLabel.textAlignment = NSTextAlignmentCenter;
    return institutionLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    /*
    *** This has been commented out for a reason. The school should not be set until the continue button is pressed because the previous methd of setting the institution could produce an error. If the user wished to select the first institution, but there was already an institution in user defaults then the institution would not be properly set.
    ***
     
    Institution * institution = (Institution*)[self.institutions objectAtIndex:row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:institution.id forKey:@"institution_id"];
    NSLog(@"selected institution: %@ with id: %@",institution.name,institution.id);
     */
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

- (IBAction)continueButton:(id)sender
{
    // sets the institution when continue is pressed
    Institution * institution = (Institution*)[self.institutions objectAtIndex:[self.schoolPicker selectedRowInComponent:0]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:institution.id forKey:@"institution_id"];
    NSLog(@"selected institution: %@ with id: %@",institution.name,institution.id);
    
    PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [[PAFetchManager sharedFetchManager] switchInstitution];
    
    // if this is root because of the initial download of the app
    if ([appDelegate window].rootViewController == self) {
        UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
        
        [appDelegate.window setRootViewController:newRoot];
    } else {
    
        [self.navigationController popViewControllerAnimated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
