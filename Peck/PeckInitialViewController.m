//
//  PeckInitialViewController.m
//  PeckDev
//
//  Created by Aaron Taylor on 3/6/14.
//  Copyright (c) 2014 Peck App. All rights reserved.
//

#import "PeckInitialViewController.h"

@interface PeckInitialViewController ()

@property (strong,nonatomic) NSArray* schoolList;

@end

@implementation PeckInitialViewController

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
    self.schoolList = @[@"Williams",@"Exeter",@"Middlebury"];
    
    self.schoolPicker.dataSource = self;
    self.schoolPicker.delegate = self;
    
    [self.schoolPicker reloadAllComponents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //sets the school string in NSUserDefaults for future reference
    [[NSUserDefaults standardUserDefaults] setObject:self.schoolList[[self.schoolPicker selectedRowInComponent:0]] forKey:@"school"];
    
    //sets the loginSaved BOOL to YES to avoid login screen in the future
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loginSaved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Picker view data source

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.schoolList count];
}

#pragma mark - Picker view delegate

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.schoolList[row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

@end
