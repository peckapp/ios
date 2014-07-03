//
//  PAEventInfoTableViewController.m
//  Peck
//
//  Created by John Karabinos on 7/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAEventInfoTableViewController.h"
#import "PACommentCell.h"

@interface PAEventInfoTableViewController ()
@property (nonatomic, retain) NSDateFormatter *formatter;

@end

@implementation PAEventInfoTableViewController

@synthesize startTimeLabel = _startTimeLabel;
@synthesize endTimeLabel = _endTimeLabel;
@synthesize descriptionTextView = _blurbTextView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSString * cellIdentifier = @"CommentCell";
NSString * nibName = @"PACommentCell";
NSMutableDictionary *heightDictionary;

BOOL reloaded = NO;
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
    //if(!self.formatter){
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
    //}
    [self.descriptionTextView setEditable:NO];
    [self configureView];
    heightDictionary = [[NSMutableDictionary alloc] init];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        NSLog(@"the event: %@", _detailItem);
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        
        self.title = [self.detailItem valueForKey:@"title"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM dd, yyyy h:mm a"];
        NSString *stringFromDate =[df stringFromDate:[self.detailItem valueForKey:@"start_date"]];
        [self.startTimeLabel setText: stringFromDate];
        [self.endTimeLabel setText:[df stringFromDate:[self.detailItem valueForKey:@"end_date"]]];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return [[_fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    //id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    //return [sectionInfo numberOfObjects];
    return 4;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(PACommentCell *)cell atIndexPath: (NSIndexPath *)indexPath{
    cell.nameLabel.text = @"John Doe";
    cell.parentTableView=self;
    cell.tag = [indexPath row];
    cell.commentTextView.text = @"this is the longest comment known to man. aaaaaaaaaaaaaa so long aaaaaaaaaa this comment is so so so so so so so so so longggggggggggggggggggggg i can't even believe how long it is! wow this comment is long oh my gosh i can't stop typing this long long comment.this is the longest comment known to man. aaaaaaaaaaaaaa so long aaaaaaaaaa this comment is so so so so so so so so so longggggggggggggggggggggg i can't even believe how long it is! wow this comment is long oh my gosh i can't stop typing this long long comment.";
    
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"height for row at index path");
    //CGFloat height = ((PACommentCell*)[tableView cellForRowAtIndexPath:indexPath]).commentTextView.contentSize.height;
    NSString * cellTag = [@([indexPath row]) stringValue];
    
    CGFloat height = [[heightDictionary valueForKey:cellTag] floatValue];
    if(height){
        NSLog(@"setting the new height of the frame %f", height);
        return height;
    }
    return 120;
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

- (void)expandTableViewCell:(PACommentCell *)cell {
    NSLog(@"expand table view cell");
    [cell.commentTextView sizeToFit];
    [cell.commentTextView layoutSubviews];
    NSLog(@"new frame size %f", cell.commentTextView.frame.size.height);
    NSNumber *height = [NSNumber numberWithFloat:120];
    if(cell.commentTextView.frame.size.height>120){
        height = [NSNumber numberWithFloat:cell.commentTextView.frame.size.height];
    }
    NSString * cellTag = [@(cell.tag) stringValue];
    [heightDictionary setValue:height forKey:cellTag];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
}

-(void)compressTableViewCell:(PACommentCell *)cell{
    cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, 119);
    NSString *cellTag = [@(cell.tag) stringValue];
    [heightDictionary removeObjectForKey:cellTag];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
