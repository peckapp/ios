//
//  PAInvitationsTableViewController.m
//  Peck
//
//  Created by John Karabinos on 7/18/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAInvitationsTableViewController.h"
#import "PAInvitationCell.h"
#import "Circle.h"
#import "Peer.h"
#import "PAAppDelegate.h"
#import "PASyncManager.h"
#import "PAPostViewController.h"


@interface PAInvitationsTableViewController ()

@end

@implementation PAInvitationsTableViewController

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
    
    [[PASyncManager globalSyncManager] updateCircleInfo];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.suggestedInvites = [[NSMutableArray alloc] init];
    if(!self.invitedPeople){
        self.invitedPeople = [[NSMutableDictionary alloc] init];
    }if(!self.invitedCircles){
        self.invitedCircles = [[NSMutableDictionary alloc] init];
    }
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Invite a circle or friend...";
    
    self.invitedPeopleTableView.delegate = self;
    self.invitedPeopleTableView.dataSource = self;
    
    self.invitedPeopleTableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    self.invitedPeopleTableView.frame = CGRectMake(0, 44, self.view.frame.size.width, 44);
    self.invitedPeopleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@",
                               searchText];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    
    NSFetchRequest *circleFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *circleEntity = [NSEntityDescription entityForName:@"Circle" inManagedObjectContext:self.managedObjectContext];
    [circleFetchRequest setEntity:circleEntity];
    
    NSPredicate *circlePredicate = [NSPredicate predicateWithFormat:@"circleName BEGINSWITH[c] %@",
                              searchText];
    [circleFetchRequest setPredicate:circlePredicate];
    
    NSError *circleError = nil;
    NSMutableArray *mutableCircleFetchResults = [[_managedObjectContext executeFetchRequest:circleFetchRequest error:&circleError] mutableCopy];

    
    
    for(int i=0;i<[mutableFetchResults count];i++){
        Peer* tempPeer = mutableFetchResults[i];
        if([self.invitedPeople objectForKey:[tempPeer.id stringValue]]){
            [mutableFetchResults removeObjectAtIndex:i];
            i--;
        }
    }
    
    for(int i=0;i<[mutableCircleFetchResults count];i++){
        Circle* tempCircle = mutableCircleFetchResults[i];
        if([self.invitedCircles objectForKey:[tempCircle.id stringValue]]){
            [mutableCircleFetchResults removeObjectAtIndex:i];
            i--;
        }
    }
    
    self.suggestedInvites=(NSMutableArray*)[mutableCircleFetchResults arrayByAddingObjectsFromArray:mutableFetchResults];
    
    
    
    [self.tableView reloadData];
    [self.invitedPeopleTableView reloadData];
    
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
    if(tableView==self.tableView){
        return [self.suggestedInvites count];
    }else{
        return [self.invitedPeople count]+[self.invitedCircles count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView==self.invitedPeopleTableView){
        return 44;
    }
    return 71;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView==self.tableView){
        PAInvitationCell * cell = [tableView dequeueReusableCellWithIdentifier:@"invitationCell"];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"PAInvitationCell" bundle:nil]  forCellReuseIdentifier:@"invitationCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"invitationCell"];
        }
    
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invite"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"invite"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [self configurePreviewCell:cell atIndexPath:indexPath];
        return cell;

    }
}

-(void)configurePreviewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    if([self.invitedCircles count]>indexPath.row){
        cell.backgroundColor = [UIColor blackColor];
    }
    

    else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    
    cell.transform = CGAffineTransformMakeRotation(M_PI_2);
}

-(void)configureCell:(PAInvitationCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    if([self.suggestedInvites[indexPath.row] isKindOfClass:[Circle class]]){
        Circle* tempCircle = self.suggestedInvites[indexPath.row];
        cell.nameLabel.text = tempCircle.circleName;
        cell.picture.image = [UIImage imageNamed:@"circles.jpeg"];
        
    }else if([self.suggestedInvites[indexPath.row] isKindOfClass:[Peer class]]){
        Peer* tempPeer = self.suggestedInvites[indexPath.row];
        cell.nameLabel.text = tempPeer.name;
        cell.picture.image = [UIImage imageNamed:@"profile_placeholder.png"];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView==self.tableView){
        if([self.suggestedInvites[indexPath.row] isKindOfClass:[Circle class]]){
            Circle* tempCircle = self.suggestedInvites[indexPath.row];
            [self.invitedCircles setObject:tempCircle.id forKey:[tempCircle.id stringValue]];
        }else if([self.suggestedInvites[indexPath.row] isKindOfClass:[Peer class]]){
            Peer* tempPeer = self.suggestedInvites[indexPath.row];
            [self.invitedPeople setObject:tempPeer.id forKey:[tempPeer.id stringValue]];
        }
        NSLog(@"invited people: %@", self.invitedPeople);
        NSLog(@"invited circles: %@", self.invitedCircles);
        self.searchBar.text=@"";
        [self searchBar:self.searchBar textDidChange:@""];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else{
        
    }
    
    
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (IBAction)addInvites:(id)sender {
    NSLog(@"invite the people");
    PAPostViewController* parent = (PAPostViewController*)self.parentPostViewController;
    parent.invitedPeople = [self.invitedPeople allValues];
    parent.invitedCircles = [self.invitedCircles allValues];
    
    parent.invitedPeopleDictionary = self.invitedPeople;
    parent.invitedCirclesDictionary = self.invitedCircles;
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];

}
@end
