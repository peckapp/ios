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
#import "PASyncManager.h"
#import "HTAutocompleteManager.h"

@interface PACreateCircleViewController ()

@end

@implementation PACreateCircleViewController
   


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize titleTextField, membersAutocompleteTextField;
@synthesize titleLabel;
@synthesize addedPeers = _addedPeers;


//PACircleScrollView *circleScrollView;

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

    if(!_addedPeers){
        _addedPeers = [NSMutableArray array];
    }
    
    
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
    //if(![membersAutocompleteTextField.text isEqualToString:@""]){
    Peer *tempPeer = [HTAutocompleteManager sharedManager].currentPeer;
    if(tempPeer){
        NSLog(@"choose a member");
        NSString *tempText= membersAutocompleteTextField.text;
        tempText = [tempText stringByAppendingString:membersAutocompleteTextField.autocompleteLabel.text];
        //membersAutocompleteTextField.text = [tempText stringByAppendingString:@", "];
        membersAutocompleteTextField.text=@"";
        membersAutocompleteTextField.autocompleteLabel.text=@"";
        
        if(!_addedPeers){
            _addedPeers = [NSMutableArray array];
        }

        Peer * tempPeer = [HTAutocompleteManager sharedManager].currentPeer;
        [_addedPeers addObject:tempPeer.id];
        NSLog(@"peers added so far: %@", _addedPeers);
        UIImage *image = [UIImage imageNamed:@"Silhouette.png"];
        
        [membersAutocompleteTextField forceRefreshAutocompleteText];
    }
}

-(void)textFieldDidChange{
    titleLabel.text = titleTextField.text;

}

- (IBAction)createCircleButton:(id)sender {
    // doesn't submit an titleless circle
    BOOL titleIsEmpty = [titleTextField.text isEqualToString:@""];
    if (!titleIsEmpty) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *userID = [defaults objectForKey: @"user_id"];
        
        NSDictionary *setCircle = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:1], @"institution_id",
                                   titleTextField.text, @"circle_name",
                                   userID, @"user_id",
                                   _addedPeers,@"circle_members",
                                   nil];
        [[PASyncManager globalSyncManager] postCircle:setCircle];
        [[PASyncManager globalSyncManager] updateCircleInfo];
    } else {
        NSLog(@"attempted to create a circle without a title");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Title"
                                                        message:@"You must enter a title for the circle"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelCreateCircle:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)removePeer:(int) peer{
    
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField==membersAutocompleteTextField){
        membersAutocompleteTextField.autocompleteLabel.text=@"";
    }
}

@end
