//
//  PASubscriptionsTableViewController.m
//  Peck
//
//  Created by John Karabinos on 7/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASubscriptionsTableViewController.h"
#import "PASubscriptionCell.h"
#import "PAFetchManager.h"
#import "Subscription.h"
#import "PASyncManager.h"

@interface PASubscriptionsTableViewController ()

@end

@implementation PASubscriptionsTableViewController

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
    
    NSLog(@"view did load");
    
    self.departmentSubscriptions = [[PAFetchManager sharedFetchManager] fetchSubscriptionsForCategory:@"department"];
    self.clubSubscriptions = [[PAFetchManager sharedFetchManager] fetchSubscriptionsForCategory:@"club"];
    self.athleticSubscriptions = [[PAFetchManager sharedFetchManager] fetchSubscriptionsForCategory:@"athletic"];
    
    self.addedSubscriptions = [[NSMutableDictionary alloc] init];
    self.deletedSubscriptions = [[NSMutableDictionary alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"view will disappear");
    [[PASyncManager globalSyncManager] postSubscriptions:[self.addedSubscriptions allValues]];
    [[PASyncManager globalSyncManager] deleteSubscriptions:[self.deletedSubscriptions allValues]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section==0)
        return [self.departmentSubscriptions count];
    else if(section==1)
        return [self.clubSubscriptions count];
    else
        return [self.athleticSubscriptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PASubscriptionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"subscriptionCell"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PASubscriptionCell" bundle:nil]  forCellReuseIdentifier:@"subscriptionCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"subscriptionCell"];
    }

    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


-(void)configureCell:(PASubscriptionCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    cell.parentViewController = self;
    Subscription* tempSubscription;
    if(indexPath.section==0){
        tempSubscription = self.departmentSubscriptions[indexPath.row];
    }else if(indexPath.section==1){
        tempSubscription = self.clubSubscriptions[indexPath.row];
    }else if(indexPath.section==2){
        tempSubscription = self.athleticSubscriptions[indexPath.row];
    }
    cell.subscriptionTitle.text = tempSubscription.name;
    cell.subscription = tempSubscription;
    BOOL subscribed = [tempSubscription.subscribed boolValue];
    if(subscribed){
        cell.subscriptionSwitch.on =YES;
    }else{
        cell.subscriptionSwitch.on = NO;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(section==0){
        return @"Departments";
    }else if(section==1){
        return @"Clubs";
    }else{
        return @"Athletics";
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"preparing for segue!!!!!");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
