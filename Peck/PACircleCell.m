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

@implementation PACircleCell
@synthesize members = _members;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)awakeFromNib
{
    // Initialization code

    /*[scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(800, 0)];
     */
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.scrollView action:@selector (selectProfile:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapRecognizer];
    self.scrollView.userInteractionEnabled = YES;

    _loadedImages = NO;

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.profileList.delegate = self;
    self.profileList.dataSource = self;

    self.profileList.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.profileList.frame = CGRectMake(0, 44.0, self.frame.size.width, 44.0);
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
}

- (void)expand
{
    // TODO: handle expansion
    self.commentsTable.hidden = NO;
}

- (void)contract
{
    // TODO: handle contraction
    self.commentsTable.hidden = YES;
}


-(Peer *)peer:(NSNumber*)peerID{
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *attributeName = @"id";
    NSNumber *attributeValue = peerID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",
                              attributeName, attributeValue];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    Peer *peer = mutableFetchResults[0];
    
    
    return peer;
}

#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0) {
        return 20;
    }
    else {
        return 0;
    }
}

#pragma mark Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 0) {
        UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = [UIColor grayColor];
        }
        else {
            cell.backgroundColor = [UIColor lightGrayColor];
        }

        cell.transform = CGAffineTransformMakeRotation(-M_PI_2);
        return cell;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
