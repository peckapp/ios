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
#import "PAAssetManager.h"
#import "UIImageView+AFNetworking.h"
#import "PAFetchManager.h"

@interface PAInvitationsTableViewController ()

@end

@implementation PAInvitationsTableViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

PAAssetManager * assetManager;

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
    assetManager = [PAAssetManager sharedManager];
    
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
    
    /*
    self.invitedPeopleTableView.delegate = self;
    self.invitedPeopleTableView.dataSource = self;
    
    self.invitedPeopleTableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    self.invitedPeopleTableView.frame = CGRectMake(0, 44, self.view.frame.size.width, 44);
    self.invitedPeopleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;*/
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
    //[self.invitedPeopleTableView reloadData];
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
    
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0){
        return @"Suggested Invites";
    }
    return @"Added Members";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section==0){
        return [self.suggestedInvites count];
    }else{
        return [self.invitedPeople count]+[self.invitedCircles count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
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
    self.invitedPeopleArray = [self.invitedPeople allValues];
    self.invitedCirclesArray = [self.invitedCircles allValues];
    if(indexPath.row<[self.invitedCirclesArray count]){
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"event-placeholder.png"]];
        cell.backgroundView = imageView;
    }else{
        NSNumber* peerID = self.invitedPeopleArray[indexPath.row - [self.invitedCirclesArray count]];
        Peer* peer = [[PAFetchManager sharedFetchManager] getPeerWithID:peerID];
        UIImageView* thumbnail = [assetManager createThumbnailWithFrame:cell.frame imageView:[self imageForPeer:peer]];

        thumbnail.userInteractionEnabled = NO;
        cell.backgroundView = thumbnail;

    }
            cell.transform = CGAffineTransformMakeRotation(M_PI_2);
}

-(void)configureCell:(PAInvitationCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    if(indexPath.section==0){
        //if we are in the add members section
        if([self.suggestedInvites[indexPath.row] isKindOfClass:[Circle class]]){
             Circle* tempCircle = self.suggestedInvites[indexPath.row];
            [self configureCircleCell:cell withCircle:tempCircle];
        
        }else if([self.suggestedInvites[indexPath.row] isKindOfClass:[Peer class]]){
            Peer* tempPeer = self.suggestedInvites[indexPath.row];
            [self configurePeerCell:cell withPeer:tempPeer];
        }
    }else{
        //if we are in the added members section
        self.invitedPeopleArray = [self.invitedPeople allValues];
        self.invitedCirclesArray = [self.invitedCircles allValues];
        if(indexPath.row<[self.invitedCirclesArray count]){
            Circle* tempCircle = [[PAFetchManager sharedFetchManager] getObject:self.invitedCirclesArray[indexPath.row] withEntityType:@"Circle" andType:nil];
            [self configureCircleCell:cell withCircle:tempCircle];
        }else{
            NSNumber* peerID = self.invitedPeopleArray[indexPath.row - [self.invitedCirclesArray count]];
            Peer* peer = [[PAFetchManager sharedFetchManager] getPeerWithID:peerID];
            [self configurePeerCell:cell withPeer:peer];
        }
    }
}

-(void)configureCircleCell:(PAInvitationCell*)cell withCircle:(Circle*)circle{
   
    cell.nameLabel.text = circle.circleName;
    if (cell.thumbnailView) {
        [cell.thumbnailView removeFromSuperview];
    }
    UIImageView * thumbnail = [assetManager createThumbnailWithFrame:cell.thumbnailViewTemplate.frame imageView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image-placeholder.png"]]];
    
    [cell addSubview:thumbnail];
    cell.thumbnailViewTemplate.backgroundColor = [UIColor whiteColor];
    cell.thumbnailView = thumbnail;

}

-(void)configurePeerCell:(PAInvitationCell*)cell withPeer:(Peer*)tempPeer{
    
    cell.nameLabel.text = tempPeer.name;
    //cell.picture.image = [UIImage imageNamed:@"event-placeholder.png"];
    UIImageView * thumbnail = [assetManager createThumbnailWithFrame:cell.thumbnailViewTemplate.frame imageView:[self imageForPeer:tempPeer]];
    if (cell.thumbnailView) {
        [cell.thumbnailView removeFromSuperview];
    }
    [cell addSubview:thumbnail];
    cell.thumbnailViewTemplate.backgroundColor = [UIColor whiteColor];
    cell.thumbnailView = thumbnail;
}

- (UIImageView *)imageForPeer:(Peer*)peer
{
    if (peer.imageURL) {
        NSURL* imageURL = [NSURL URLWithString:[@"http://loki.peckapp.com:3500" stringByAppendingString:peer.imageURL]];
        UIImage* image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
        if(image){
            return [[UIImageView alloc] initWithImage:image];
        }
        else {
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:imageURL placeholderImage:[assetManager profilePlaceholder]];
            return imageView;
        }
    }
    else {
        return [[UIImageView alloc] initWithImage:[assetManager profilePlaceholder]];
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        if([self.suggestedInvites[indexPath.row] isKindOfClass:[Circle class]]){
            Circle* tempCircle = self.suggestedInvites[indexPath.row];
            [self.invitedCircles setObject:tempCircle.id forKey:[tempCircle.id stringValue]];
        }else if([self.suggestedInvites[indexPath.row] isKindOfClass:[Peer class]]){
            Peer* tempPeer = self.suggestedInvites[indexPath.row];
            [self.invitedPeople setObject:tempPeer.id forKey:[tempPeer.id stringValue]];
        }
        NSLog(@"invited people: %@", self.invitedPeople);
        NSLog(@"invited circles: %@", self.invitedCircles);
        /*self.searchBar.text=@"";
        [self searchBar:self.searchBar textDidChange:@""];*/
    }
    else{
        
        //if the user is removing one of the invited circles or people
        self.invitedCirclesArray = [self.invitedCircles allValues];
        if(indexPath.row<[self.invitedCirclesArray count]){
            NSNumber* circleID = self.invitedCirclesArray[indexPath.row];
            [self.invitedCircles removeObjectForKey:[circleID stringValue]];
            
        }else{
            self.invitedPeopleArray = [self.invitedPeople allValues];
            NSNumber* peerID = self.invitedPeopleArray[indexPath.row - [self.invitedCirclesArray count]];
            [self.invitedPeople removeObjectForKey:[peerID stringValue]];
        }
        [self.tableView reloadData];
        
    }
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
