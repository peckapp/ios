//
//  PAEventInfoTableViewController.m
//  Peck
//
//  Created by John Karabinos on 7/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//


#import "PAAthleticEventViewController.h"
#import "PANestedInfoViewControllerPrivate.h"
#import "PACommentCell.h"
#import "PAAppDelegate.h"
#import "PASyncManager.h"
#import "Comment.h"
#import "PAFetchManager.h"
#import "UIImageView+AFNetworking.h"
#import "PAAssetManager.h"
#import "PAMethodManager.h"


@interface PAAthleticEventViewController () {
    NSString * commentCellIdentifier;
    NSString * cellNibName;
    
    BOOL reloaded;
}

@property (strong, nonatomic) UILabel *teamNameLabel;
@property (strong, nonatomic) UILabel *titleDetailLabel;
@property (strong, nonatomic) UILabel *scoreLabel;

@end

@implementation PAAthleticEventViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.category = @"athletic";
    
    commentCellIdentifier = @"AthleticCommentCell";
    cellNibName = @"PACommentCell";
    reloaded = NO;
    
    ////////////////////////////////////////////
    // type-specific user interface elements
    ////////////////////////////////////////////
    
    self.teamNameLabel = [[UILabel alloc] init];
    self.teamNameLabel.textColor = [UIColor whiteColor];
    self.teamNameLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.blurredImageView addSubview:self.teamNameLabel];
    
    // detail label with the title of the event
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.textColor = [UIColor whiteColor];
    self.titleDetailLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [self.blurredImageView addSubview:self.titleDetailLabel];
    
    
    self.fullTitleLabel = [[UILabel alloc] init];
    self.fullTitleLabel.textColor = [UIColor whiteColor];
    self.fullTitleLabel.font = [UIFont boldSystemFontOfSize:21.0];
    [self.headerView addSubview:self.fullTitleLabel];
    
    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.font = [UIFont systemFontOfSize:21.0];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:self.scoreLabel];
}

-(void)viewWillAppear:(BOOL)animated{
    //[super viewWillAppear:animated];
    
    //NSLog(@"event info view will appear");
    
    /*
     
     //[self registerForKeyboardNotifications];
     NSString *eventID = [[self.detailItem valueForKey:@"id"] stringValue];
     
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
     while(self.expanded) {
     [[PASyncManager globalSyncManager] updateCommentsFrom:eventID withCategory:@"simple"];
     [NSThread sleepForTimeInterval:reloadTime];
     }
     });
     */
    
    self.view.frame = self.parentViewController.view.bounds;
    [self updateFrames];
}

- (void)updateFrames
{
    [super updateFrames];
    
    //NSLog(@"event info frame width: %f", self.view.frame.size.width);
    //NSLog(@"event info frame height: %f", self.view.frame.size.height);
    
    //self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 88);
    
    CGRect left;
    CGRect right;
    CGRectDivide(self.blurredImageView.frame, &left, &right, titleLabelDivide, CGRectMinXEdge);
    self.timeLabel.frame = left;
    self.teamNameLabel.frame = right;
    self.teamNameLabel.frame = CGRectOffset(CGRectInset(self.teamNameLabel.frame, buffer, 0), 0, -titleAndNameSpacing);
    
    self.titleDetailLabel.frame = right;
    self.titleDetailLabel.frame = CGRectOffset(CGRectInset(self.titleDetailLabel.frame, buffer, 0), 0, titleAndNameSpacing);
    
//    self.fullTitleLabel.frame = CGRectMake(buffer, -buffer * 3, self.view.frame.size.width - buffer * 2, buffer * 3);
    
    CGFloat fullTitleSize = buffer * 3;
    self.fullTitleLabel.frame = CGRectMake(0, 0, self.view.frame.size.width - buffer * 2, fullTitleSize);
    [self.fullTitleLabel sizeToFit];
    self.fullTitleLabel.frame = CGRectMake(0, - (self.fullTitleLabel.frame.size.height+buffer), self.view.frame.size.width, self.fullTitleLabel.frame.size.height+buffer);
    
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, imageHeight);
    self.dateLabel.frame = CGRectInset(self.headerView.frame, buffer, buffer);
    [self.dateLabel sizeToFit];
    
    CGFloat attendIconSize = self.blurredImageView.frame.size.height * attendIconRatio;
    CGFloat attendX = self.timeLabel.frame.origin.x + 0.5*self.timeLabel.frame.size.width;
    CGFloat attendY = self.timeLabel.frame.origin.y + 0.2*self.blurredImageView.frame.size.height;
    CGRect attendRect = CGRectMake(attendX, attendY, attendIconSize, attendIconSize);
    self.attendingIcon.frame = attendRect;
    
    self.attendButton.frame = CGRectMake(dateLabelDivide, 0, self.view.frame.size.width - dateLabelDivide, 50);
    self.attendeesLabel.frame = CGRectMake(self.view.frame.size.width - 20, 0, 20, 50);

    self.scoreLabel.frame = CGRectMake(dateLabelDivide, 50, self.view.frame.size.width - dateLabelDivide, 21);

    CGRect description = CGRectMake(0, 0, dateLabelDivide, self.headerView.frame.size.height);
    self.descriptionLabel.frame = CGRectOffset(CGRectInset(description, buffer, buffer), 0, CGRectGetMaxY(self.dateLabel.frame));
    [self.descriptionLabel sizeToFit];

    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMaxY(self.descriptionLabel.frame) + buffer);
    
    self.footerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 1000);
    self.footerView.backgroundColor = [UIColor whiteColor];
    
    self.keyboardAccessoryView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.keyboardAccessory.frame = CGRectMake(7, 7, self.view.frame.size.width - 14, 30);
    self.postButton.frame = CGRectMake(self.keyboardAccessoryView.frame.size.width - self.keyboardAccessoryView.frame.size.height, 0, self.keyboardAccessoryView.frame.size.height, self.keyboardAccessoryView.frame.size.height);
    
    [self.keyboardAccessory resignFirstResponder];
}

- (void)expandAnimated:(BOOL)animated
{
    if (!self.expanded) {
        //self.tableView = nil;
        self.fetchedResultsController = nil;
        
        NSError * error = nil;
        if (![self.fetchedResultsController performFetch:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        self.view.frame = self.parentViewController.view.bounds;
        //NSLog(@"view frame %@", NSStringFromCGRect(self.view.frame));
        self.view.backgroundColor = [UIColor whiteColor];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.tableHeaderView = self.headerView;
        self.tableView.tableFooterView = self.footerView;
        [self.view addSubview:self.tableView];
        self.tableView.frame = self.view.frame;
        self.tableView.contentInset = UIEdgeInsetsMake(imageHeight, 0, self.keyboardAccessoryView.frame.size.height - self.footerView.frame.size.height, 0);
        [self updateFrames];
        [self.view addSubview:self.keyboardAccessoryView];
        
        self.cleanImageView.hidden = NO;
        
        [self configureView];
        
        void (^animationsBlock)(void) = ^{
            self.imagesView.frame = CGRectMake(0, 0, self.view.frame.size.width, imageHeight);
            self.cleanImageView.frame = self.imagesView.frame;
            self.blurredImageView.frame = self.imagesView.frame;
            self.blurredImageView.alpha = 0;
        };
        
        void (^completionBlock)(BOOL) = ^(BOOL finished){
            self.expanded = YES;
            
            
            NSString *eventID = [[self.detailItem valueForKey:@"id"] stringValue];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                while(self.expanded) {
                    [[PASyncManager globalSyncManager] updateCommentsFrom:eventID withCategory:self.category];
                    [NSThread sleepForTimeInterval:reloadTime];
                }
            });
            
            [self registerForKeyboardNotifications];
            //NSLog(@"bounds:  %@", NSStringFromCGRect(self.parentViewController.view.bounds));
            self.view.frame = self.parentViewController.view.bounds;
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:animationsBlock
                             completion:completionBlock];
        }
        else {
            animationsBlock();
            completionBlock(true);
        }
    }
}

- (void)compressAnimated:(BOOL)animated
{
    if (self.expanded) {
        
        [self.keyboardAccessory resignFirstResponder];
        [self deregisterFromKeyboardNotifications];
        self.view.backgroundColor = [[PAAssetManager sharedManager] darkColor];
        [self.tableView setContentOffset:CGPointMake(0, -imageHeight) animated:YES];
        
        void (^animationsBlock)(void) = ^{
            self.imagesView.frame = CGRectMake(0, 0, self.view.frame.size.width, compressedHeight);
            self.cleanImageView.frame = self.imagesView.frame;
            self.blurredImageView.frame = self.imagesView.frame;
            self.blurredImageView.alpha = 1;
        };
        
        void (^completionBlock)(BOOL) = ^(BOOL finished){
            [self.keyboardAccessoryView removeFromSuperview];
            [self.tableView removeFromSuperview];
            self.tableView = nil;
            _fetchedResultsController = nil;
            
            self.cleanImageView.hidden = YES;
            self.expanded = NO;
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:animationsBlock
                             completion:completionBlock];
        }
        else {
            animationsBlock();
            completionBlock(true);
        }
    }
}

- (UIView *)viewForBackButton
{
    return self.view;
}

#pragma mark - managing the detail item

- (void)setManagedObject:(NSManagedObject *)managedObject parentObject:(NSManagedObject *)parentObject
{
    if (self.detailItem != managedObject) {
        self.detailItem = managedObject;
        // Update the view.
        [self configureView];
        //[self.tableView beginUpdates];
        //[self.tableView endUpdates];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        [super configureView];
        /*
         self.title = [self.detailItem valueForKey:@"title"];
         self.nameLabel.text = [self.detailItem valueForKey:@"title"];
         
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateFormat:@"MMM dd, yyyy h:mm a"];
         [self.startTimeLabel setText:[dateFormatter stringFromDate:[self.detailItem valueForKey:@"start_date"]]];
         [self.endTimeLabel setText:[dateFormatter stringFromDate:[self.detailItem valueForKey:@"end_date"]]];
         
         self.descriptionTextView.text = [self.detailItem valueForKey:@"descrip"];
         */
        
        [self reloadAttendeeLabels];
        // sets the attending icon to the proper value based on listed attendees for the event
        self.attendingIcon.image = [self attendingEvent] ? self.attendImage : self.nullAttendImage;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [self.timeLabel setText:[dateFormatter stringFromDate:[self.detailItem valueForKey:@"start_date"]]];

        self.teamNameLabel.text = [self.detailItem valueForKey:@"team_name"];
        self.titleDetailLabel.text = [self.detailItem valueForKey:@"title"];
        self.fullTitleLabel.text = [self.detailItem valueForKey:@"title"];
        
        [dateFormatter setDateFormat:@"MMM dd, yyyy h:mm a"];
        [self.dateLabel setText:[dateFormatter stringFromDate:[self.detailItem valueForKey:@"start_date"]]];
        
        self.descriptionLabel.text = [self.detailItem valueForKey:@"descrip"];

        // TODO: grab score from the database
        self.scoreLabel.text = @"0 - 0";
        
        // moved to superclass
//        UIImage* image = nil;
//        if ([self.detailItem valueForKey:@"imageURL"]) {
//            NSURL* imageURL = [NSURL URLWithString:[self.detailItem valueForKey:@"imageURL"]];
//            UIImage* cachedImage = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
//            if (cachedImage) {
//                self.cleanImageView.image = cachedImage;
//            }
//            else {
//                [self.cleanImageView setImageWithURL:imageURL placeholderImage:image];
//            }
//        }
//        else {
//            self.cleanImageView.image = image;
//        }
//        
//        if ([self.detailItem valueForKey:@"imageURL"]) {
//            NSURL* imageURL = [NSURL URLWithString:[self.detailItem valueForKey:@"blurredImageURL"]];
//            UIImage* cachedImage = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
//            if (cachedImage) {
//                self.blurredImageView.image = cachedImage;
//            }
//            else {
//                [self.blurredImageView setImageWithURL:imageURL placeholderImage:image];
//            }
//        }
//        else {
//            self.blurredImageView.image = image;
//        }
    }
    
    [self updateFrames];
}

-(void)reloadAttendeeLabels{
    NSArray* attendees = [self.detailItem valueForKey:@"attendees"];
    if(![attendees isKindOfClass:[NSNull class]]){
        self.attendeesLabel.text = [@([[self.detailItem valueForKey:@"attendees"] count]) stringValue];
    }
    if([self attendingEvent]){
        [self.attendButton setTitle:@"Unattend" forState:UIControlStateNormal];
    }else{
        [self.attendButton setTitle:@"Attend" forState:UIControlStateNormal];
    }
        
}


-(BOOL)attendingEvent{
    NSArray* attendees = [self.detailItem valueForKey:@"attendees"];
    if(![attendees isKindOfClass:[NSNull class]]){
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSInteger userID = [[defaults objectForKey:@"user_id"] integerValue];
        for(int i = 0; i<[attendees count];i++){
            if(userID==[attendees[i] integerValue]){
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - managing the fetched results controller

-(NSFetchedResultsController *)fetchedResultsController{
    NSLog(@"configuring the fetched results controller");
    if(_fetchedResultsController){
        return _fetchedResultsController;
    }
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSMutableArray *predicateArray =[[NSMutableArray alloc] init];
    
    NSPredicate *commentFromPredicate = [NSPredicate predicateWithFormat:@"comment_from = %@", [self.detailItem valueForKey:@"id"]];
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category like %@", self.category];
    
    [predicateArray addObject:commentFromPredicate];
    [predicateArray addObject:categoryPredicate];
    
    NSPredicate *compoundPredicate= [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
    [fetchRequest setPredicate:compoundPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:_managedObjectContext
                                                             sectionNameKeyPath:nil //this needs to be nil
                                                             cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    NSLog(@"number of fetched objects: %lu", (unsigned long)[aFetchedResultsController.fetchedObjects count]);
    self.fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    //NSLog(@"did change object");
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:{
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        }
        case NSFetchedResultsChangeDelete:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            
            PACommentCell * cell = (PACommentCell *)[tableView cellForRowAtIndexPath:newIndexPath];
            [self configureCell:cell atIndexPath:newIndexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent: (NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    //    return [[_fetchedResultsController sections] count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PACommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:cellNibName bundle:nil] forCellReuseIdentifier:commentCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(PACommentCell *)cell atIndexPath: (NSIndexPath *)indexPath{
    NSLog(@"configure cell");
    cell.parentTableView = (UITableViewController*)self;
    
    //Comment *tempComment = _fetchedResultsController.fetchedObjects[[indexPath row]];
    Comment* tempComment = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.numberOfLikesLabel.text = [@([tempComment.likes count]) stringValue];
    [cell.likeButton setHidden:NO];
    [cell.numberOfLikesLabel setHidden:NO];
    cell.commentor_id = tempComment.peer_id;
    if([self userHasLikedComment:tempComment]){
        [cell.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    }else{
        [cell.likeButton setTitle:@"Like" forState:UIControlStateNormal];
    }
    
    cell.commentID = tempComment.id;
    cell.commentIntegerID = [tempComment.id integerValue];
    //cell.comment = tempComment;
    cell.comment_from = [[self.detailItem valueForKey:@"id"] stringValue];
    cell.nameLabel.text = [self nameLabelTextForComment:tempComment];
    cell.commentTextView.text = tempComment.content;
    
    UIImageView * thumbnail = [[PAAssetManager sharedManager] createThumbnailWithFrame:cell.thumbnailViewTemplate.frame imageView:[self imageViewForComment:tempComment]];
    if (cell.thumbnailView) {
        [cell.thumbnailView removeFromSuperview];
    }
    [cell addSubview:thumbnail];
    cell.thumbnailView = thumbnail;
    
    NSString * commentID = [tempComment.id stringValue];
    CGFloat height = [[self.heightDictionary valueForKey:commentID] floatValue];
    if(height){
        cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, height);
        cell.expanded=YES;
        //[cell.expandButton setTitle:@"Hide" forState:UIControlStateNormal];
    }
    else{
        cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCellHeight);
        //using the default cell height used to show half a line, but now with autolayout constraints it displays correctly
        cell.expanded=NO;
        //[cell.expandButton setTitle:@"More" forState:UIControlStateNormal];
    }
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PACommentCell * cell = (PACommentCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.expanded) {
        [self compressTableViewCell:cell];
        cell.expanded = NO;
    }
    else {
        [self expandTableViewCell:cell];
        cell.expanded = YES;
    }
}


@end
