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
#import "PASubscriptionsTableViewController.h"
#import "PAInitialViewController.h"
#import "PAMethodManager.h"

@interface PAConfigureViewController ()

@property (nonatomic,retain) NSArray * institutions;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

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
    
    if (self.mode != PAViewControllerModeInitializing) {
        [self.loginButton setHidden:YES];
        [self.loginButton setEnabled:NO];
    }
    
    // commented out because it just causes a 401 on initial launch
    // method is called by the SyncManager in sucess block of sendUDIDForInitViewController
    //[self updateInstitutions];
    
    [schoolPicker reloadAllComponents];
    
    
    [self selectCurrentDefaultIfExists];
}

-(void)viewWillAppear:(BOOL)animated {
    // set institution id back to nil if the user cancels the login screen
    if (self.mode == PAViewControllerModeInitializing) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"institution_id"];
    }
}

-(void)updateInstitutions{
    [[PASyncManager globalSyncManager] updateAvailableInstitutionsWithCallback:^(BOOL success) {
        if (success) {
            NSLog(@"executing callback for institution configurator");
            BOOL selectCurrent = YES;
            if([self.institutions count]>0){
                selectCurrent=NO;
            }
            self.institutions = [self fetchInstitutions];
            [self.schoolPicker reloadAllComponents];
            
            if(selectCurrent){
                [self selectCurrentDefaultIfExists];
            }
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

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    // the number of institutions in the current array
    return self.institutions.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
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
    *** This has been commented out for a reason. The school should not be set until the continue button is pressed because the previous method of setting the institution could produce an error. If the user wished to select the first institution, but there was already an institution in user defaults then the institution would not be properly set.
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

#pragma mark - Navigation

- (IBAction)continueButton:(id)sender
{
    if ([self storeSelectedInstitution] == NO) {
        // cannot continue if no institution was selected
        return;
    }
    
    [[PAFetchManager sharedFetchManager] switchInstitution];
    
    // if this is root because of the initial download of the app
    if ([[[UIApplication sharedApplication] delegate] window].rootViewController == self.navigationController) {
        [self performSegueWithIdentifier:@"initialSubscriptions" sender:self];
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)loginButton:(id)sender {
    if ([self storeSelectedInstitution] == false) {
        // must select an institution before logging in
        return;
    }
    
    // gaurd clause for missing internet connection
    if ([[PAMethodManager sharedMethodManager] serverIsReachable] == NO) {
        [[PAMethodManager sharedMethodManager] showNoInternetAlertWithTitle:@"No Connection"
                                                                 AndMessage:@"It seems that you are unble to connect to our servers."];
        return;
    }
    
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UINavigationController *loginRoot = [loginStoryboard instantiateInitialViewController];
    PAInitialViewController* init = loginRoot.viewControllers[0];
    init.direction = @"initialize";
    init.mode = PAViewControllerModeInitializing;
    [self presentViewController:loginRoot animated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"initialSubscriptions"]) {
        [(PASubscriptionsTableViewController*)segue.destinationViewController setIsInitializing:YES];
    }
}

- (BOOL) storeSelectedInstitution {
    // sets the institution when continue is pressed
    Institution * institution = (Institution*)[self.institutions objectAtIndex:[self.schoolPicker selectedRowInComponent:0]];
    
    if (institution == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Institution Selected"
                                                            message:@"It seems like you were not able to select an Institution. We're looking into it!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        // should post error to flurry here
        [alertView show];
        return false;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:institution.id forKey:@"institution_id"];
    NSLog(@"selected institution: %@ with id: %@",institution.name,institution.id);
    
    return true;
}

@end
