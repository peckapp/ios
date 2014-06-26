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
#import "PACircleScrollView.h"

@interface PACreateCircleViewController ()
@property (strong, nonatomic) PACircleScrollView *circleScrollView;
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
    
    if(!self.circleScrollView){
        self.circleScrollView = [[PACircleScrollView alloc] initWithFrame:CGRectMake(100, 55, self.view.frame.size.width-100, 60)];
        [self.view addSubview:self.circleScrollView];
        self.circleScrollView.delegate=self;
    }
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
    if(![membersAutocompleteTextField.text isEqualToString:@""]){
    NSLog(@"choose a member");
    NSString *tempText= membersAutocompleteTextField.text;
    tempText = [tempText stringByAppendingString:membersAutocompleteTextField.autocompleteLabel.text];
    //membersAutocompleteTextField.text = [tempText stringByAppendingString:@", "];
    membersAutocompleteTextField.text=@"";
    membersAutocompleteTextField.autocompleteLabel.text=@"";
    [membersAutocompleteTextField forceRefreshAutocompleteText];
    if(!_addedPeers){
        _addedPeers = [NSMutableArray array];
    }

    [_addedPeers addObject:tempText];
    NSLog(@"peers added so far: %@", _addedPeers);
    UIImage *image = [UIImage imageNamed:@"Silhouette.png"];
    [self.circleScrollView addPeer:image WithName:tempText];
    }
}

-(void)textFieldDidChange{
    titleLabel.text = titleTextField.text;

}

- (IBAction)createCircleButton:(id)sender {
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    Circle * circle = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext: _managedObjectContext];
    
    [circle setCircleName:titleTextField.text];
    [circle setMembers:_addedPeers];
    
}

-(void)removePeer:(int) peer{
    if(_circleScrollView.numberOfMembers>=(peer+1)){
        [_addedPeers removeObjectAtIndex:peer];
        [self.circleScrollView removePeer:peer];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField==membersAutocompleteTextField){
        membersAutocompleteTextField.autocompleteLabel.text=@"";
    }
}

@end
