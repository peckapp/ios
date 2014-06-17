//
//  PACirclesTableViewController.m
//  Peck
//
//  Created by Aaron Taylor on 6/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACirclesTableViewController.h"
#import "PACircleCell.h"
#import "PAAppDelegate.h"
#import "Circle.h"

@interface PACirclesTableViewController ()

@end

@implementation PACirclesTableViewController

@synthesize circles = _circles;
@synthesize tableView = _tableView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Circles";
    
    _tableView.delegate=self;
    _tableView.dataSource=self;
    NSArray *members1 =@[@"A-Aron",@"D-Nice",@"TeeMothy",@"BALAKE",@"John",@"name",@"another name",@"one more"];
    NSArray *members2 =@[@"Thing 1",@"Thing 2"];
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    Circle *circle1 = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext:_managedObjectContext];
    [circle1 setCircleName:@"Physics"];
    [circle1 setMembers:members1];
    Circle *circle2 = [NSEntityDescription insertNewObjectForEntityForName:@"Circle" inManagedObjectContext:_managedObjectContext];
    [circle2 setCircleName:@"Chess Club"];
    [circle2 setMembers:members2];
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription *circles = [NSEntityDescription entityForName:@"Circle" inManagedObjectContext:_managedObjectContext];
    [request setEntity:circles];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"circleName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    self.circles = mutableFetchResults;
    NSLog(@"circles: %@", _circles);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_circles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACircleCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"PrototypeCell"];
    if (cell == nil) {
        [_tableView registerNib:[UINib nibWithNibName:@"PACircleCell" bundle:nil]  forCellReuseIdentifier:@"PrototypeCell"];
        cell = [_tableView dequeueReusableCellWithIdentifier:@"PrototypeCell"];
    }
    cell.delegate=self;
    cell.tag=[indexPath row];
    Circle * tempCircle = _circles[[indexPath row]];
    NSArray *members = tempCircle.members;
    int numberOfMembers = [members count];
    for(int i =0; i<[members count]; i++){
        NSLog(@"Member: %@", members[i]);
    }
    cell.members = numberOfMembers;
    cell.circleTitle.text = tempCircle.circleName;
    [cell.scrollView setContentSize:CGSizeMake(80*(numberOfMembers), 0)];
    [cell addImages];
    return cell;
}

# pragma mark - PACirclesControllerDelegate

-(void)Profile: (int) userID{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"FriendProfile"];
    [self presentViewController:controller animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
