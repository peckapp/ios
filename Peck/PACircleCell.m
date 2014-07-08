//
//  PACircleCellTableViewCell.m
//  Peck
//
//  Created by John Karabinos on 6/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PACircleCell.h"
#import "PACirclesTableViewController.h"
#import "PAFriendProfileViewController.h"
#import "PAAppDelegate.h"
#import "Circle.h"
#import "PACircleScrollView.h"
#import "Peer.h"
#import "PACommentCell.h"

@interface PACircleCell ()

@end

@implementation PACircleCell
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString * commentCellIdentifier = @"CircleCommentCell";
NSString * commentCellNibName = @"PACommentCell";

- (void)awakeFromNib
{
    // Initialization code

    /*[scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(800, 0)];
     */

    _loadedImages = NO;

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.profilesTableView.delegate = self;
    self.profilesTableView.dataSource = self;

    self.profilesTableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.profilesTableView.frame = CGRectMake(0, 44.0, self.frame.size.width, 44.0);

    self.commentsTableView.delegate=self;
    self.commentsTableView.dataSource=self;
    
    
    self.members = [[NSMutableArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected) {
        [self expand];
    }
    else {
        [self contract];
    }
}

-(void)selectProfile: (UIGestureRecognizer*) sender{
    //CGPoint tapPoint = [sender locationInView:scrollView];
    //NSLog(@"cell: %i, x location: %f", self.tag, tapPoint.x);
    //[_delegate profile:2];

    //get the cell and the picture that has been selected and open that profile
}


-(void)addImages: (NSArray *)members{
    /*
    //TODO: fix this code so that reloading the table view does not reallocate
    NSLog(@"number of members: %lu", (unsigned long)[members count]);
    if([members count] != self.scrollView.numberOfMembers){
        //TODO: this if statement is not very robust, unnecessary images will be added if one member is added to the circle.
        //consider changing it to if numberOfMembers==0 or something similar
        for(int i = 0; i <[members count]; i++){
            Peer *tempPeer = [self peer:members[i]];
            NSLog(@"adding an image");
        
            UIImage *image = [UIImage imageNamed:@"profile-placeholder.png"];
            NSString *name = tempPeer.name;
            //use the id's in members to get the correct images
            [self.scrollView addPeer:image WithName:name];
        }
    }_loadedImages=YES;
     */
}

-(void)updateCircleMembers:(NSMutableArray *)circleMembers{
    //we will use members to configure the cells of the members
    //it is an array of peers
    self.members=circleMembers;
    [self.profilesTableView reloadData];
}

- (void)addMember:(NSNumber *)member
{

}

- (void)expand
{
    // TODO: handle expansion
}

- (void)contract
{
    // TODO: handle contraction
}


#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.profilesTableView) {
        return [self.members count] + 1;
    }
    else if (tableView == self.commentsTableView) {
        return 3;
    }
    else {
        return 0;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


#pragma mark Table view delegate

// TODO: display profile images on table cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"circleSubcell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"circleSubcell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

    

        if (indexPath.row == [self.members count]) {
            cell.backgroundColor = [UIColor blackColor];
        }
        else if (indexPath.row % 2 == 0) {
            cell.backgroundColor = [UIColor grayColor];
        }
        else {
            cell.backgroundColor = [UIColor lightGrayColor];
        }

        cell.transform = CGAffineTransformMakeRotation(M_PI_2);
        return cell;
    }
    else if (tableView == self.commentsTableView) {
        PACommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:commentCellNibName bundle:nil] forCellReuseIdentifier:commentCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        }
        [self configureCell:cell atIndexPath:indexPath];
        return cell;

        
    }
    else {
        return nil;
    }
}

-(void)configureCell:(PACommentCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    cell.nameLabel.text = @"John Doe";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        return 44;
    }
    else if (tableView == self.commentsTableView) {
        return 120;
    }
    else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.profilesTableView) {
        if (indexPath.row == [self.members count]) {
            [self.delegate promptToAddMemberToCircleCell:self];
        }
    }
    else if (tableView == self.commentsTableView) {

    }
    else {

    }
}

@end
