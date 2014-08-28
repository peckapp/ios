//
//  PAEventInfoTableViewController.m
//  Peck
//
//  Created by John Karabinos on 7/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//


#import "PAAthleticEventViewController.h"
#import "PACommentCell.h"
#import "PAAppDelegate.h"
#import "PASyncManager.h"
#import "Comment.h"
#import "PAFetchManager.h"
#import "UIImageView+AFNetworking.h"
#import "PAAssetManager.h"
#import "PAMethodManager.h"


#define imageHeight 256
#define titleLabelDivide 90
#define dateLabelDivide 200
#define compressedHeight 88
#define buffer 14
#define defaultCellHeight 72
#define reloadTime 10


@interface PAAthleticEventViewController (){
    NSString * commentCellIdentifier;
    NSString * cellNibName;
    NSMutableDictionary *heightDictionary;
    CGRect initialFrame;
    UITextView *textViewHelper;
    
    PAAssetManager * assetManager;
    
    BOOL reloaded;
}

-(void)configureCell:(PACommentCell *)cell atIndexPath: (NSIndexPath *)indexPath;
@property (nonatomic, retain) NSDateFormatter *formatter;

@property (assign, nonatomic) BOOL expanded;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIView *imagesView;

@property (strong, nonatomic) UIImageView *cleanImageView;
@property (strong, nonatomic) UIImageView *blurredImageView;

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *fullTitleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *scoreLabel;

@property (strong, nonatomic) UIButton *attendButton;
@property (strong, nonatomic) UILabel *attendeesLabel;

@property (strong, nonatomic) UIView * keyboardAccessoryView;
@property (strong, nonatomic) UITextField * keyboardAccessory;
@property (strong, nonatomic) UIButton * postButton;

@end

@implementation PAAthleticEventViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assetManager = [PAAssetManager sharedManager];
    
    commentCellIdentifier = @"AthleticCommentCell";
    cellNibName = @"PACommentCell";
    reloaded = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //if(!self.formatter){
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MMM dd, yyyy h:mm a"];
    //}
    
    textViewHelper = [[UITextView alloc] init];
    [textViewHelper setHidden:YES];
    
    heightDictionary = [[NSMutableDictionary alloc] init];
    
    /*
     NSError * error = nil;
     if (![self.fetchedResultsController performFetch:&error])
     {
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
     */
    
    //[self configureView];
    
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [assetManager darkColor];
    
    self.headerView = [[UIView alloc] init];
    self.footerView = [[UIView alloc] init];
    self.imagesView = [[UIView alloc] init];
    
    self.cleanImageView = [[UIImageView alloc] init];
    self.cleanImageView.contentMode = UIViewContentModeCenter;
    [self.imagesView addSubview:self.cleanImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeCenter;
    [self.imagesView addSubview:self.blurredImageView];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.blurredImageView addSubview:self.timeLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.blurredImageView addSubview:self.titleLabel];
    
    [self.headerView addSubview:[assetManager createShadowWithFrame:CGRectMake(0, -64, self.view.frame.size.width, 64) top:YES]];
    
    self.fullTitleLabel = [[UILabel alloc] init];
    self.fullTitleLabel.textColor = [UIColor whiteColor];
    self.fullTitleLabel.font = [UIFont boldSystemFontOfSize:21.0];
    [self.headerView addSubview:self.fullTitleLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    [self.headerView addSubview:self.dateLabel];

    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.font = [UIFont systemFontOfSize:21.0];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:self.scoreLabel];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = [UIFont systemFontOfSize:13.0];
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descriptionLabel.numberOfLines = 0;
    [self.headerView addSubview:self.descriptionLabel];
    
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.imagesView];
    
    self.attendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.attendButton addTarget:self action:@selector(attendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.attendButton setTitle:@"Attend" forState:UIControlStateNormal];
    [self.headerView addSubview:self.attendButton];
    
    self.attendeesLabel = [[UILabel alloc] init];
    self.attendeesLabel.font = [UIFont systemFontOfSize:14.0];
    [self.headerView addSubview:self.attendeesLabel];
    
    self.keyboardAccessoryView = [[UIView alloc] init];
    self.keyboardAccessoryView.backgroundColor = [UIColor whiteColor];
    
    self.keyboardAccessory = [assetManager createTextFieldWithFrame:CGRectZero];
    self.keyboardAccessory.placeholder = @"Post a comment...";
    self.keyboardAccessory.delegate = self;
    
    [self.keyboardAccessoryView addSubview:self.keyboardAccessory];
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [self.postButton addTarget:self action:@selector(didSelectPostButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardAccessoryView addSubview:self.postButton];
    self.postButton.alpha = 0;
    
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(changeFirstResponder)
     name:UIKeyboardDidShowNotification
     object:nil];
     */
    
    [self.tableView reloadData];
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
    //NSLog(@"event info frame width: %f", self.view.frame.size.width);
    //NSLog(@"event info frame height: %f", self.view.frame.size.height);
    
    //self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 88);
    
    self.imagesView.frame = CGRectMake(0, 0, self.view.frame.size.width, compressedHeight);
    self.cleanImageView.frame = self.imagesView.frame;
    self.blurredImageView.frame = self.imagesView.frame;
    
    CGRect left;
    CGRect right;
    CGRectDivide(self.blurredImageView.frame, &left, &right, titleLabelDivide, CGRectMinXEdge);
    self.timeLabel.frame = left;
    self.titleLabel.frame = right;
    self.titleLabel.frame = CGRectInset(self.titleLabel.frame, buffer, 0);
    
    self.fullTitleLabel.frame = CGRectMake(buffer, -buffer * 3, self.view.frame.size.width - buffer * 2, buffer * 3);
    
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, imageHeight);
    self.dateLabel.frame = CGRectInset(self.headerView.frame, buffer, buffer);
    [self.dateLabel sizeToFit];
    
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

-(void)viewDidAppear:(BOOL)animated{
    initialFrame = self.tableView.frame;
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.keyboardAccessory resignFirstResponder];
    [self deregisterFromKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 //DO NOT DELETE (for now)
 #pragma mark - managing the keyboard notifications
 
 - (void)registerForKeyboardNotifications {
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWasShown:)
 name:UIKeyboardDidShowNotification
 object:nil];
 
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWillBeHidden:)
 name:UIKeyboardWillHideNotification
 object:nil];
 
 }
 
 - (void)deregisterFromKeyboardNotifications {
 
 [[NSNotificationCenter defaultCenter] removeObserver:self
 name:UIKeyboardDidHideNotification
 object:nil];
 
 [[NSNotificationCenter defaultCenter] removeObserver:self
 name:UIKeyboardWillHideNotification
 object:nil];
 
 }
 
 - (void)keyboardWasShown:(NSNotification *)notification {
 if(CGRectEqualToRect(self.tableView.frame, initialFrame)){
 NSDictionary* info = [notification userInfo];
 CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-keyboardSize.height);
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
 [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
 }
 }
 
 - (void)keyboardWillBeHidden:(NSNotification *)notification {
 self.tableView.frame = initialFrame;
 }
 */

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
        NSLog(@"view frame %@", NSStringFromCGRect(self.view.frame));
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
                    [[PASyncManager globalSyncManager] updateCommentsFrom:eventID withCategory:@"athletic"];
                    [NSThread sleepForTimeInterval:reloadTime];
                }
            });
            
            [self registerForKeyboardNotifications];
            NSLog(@"bounds:  %@", NSStringFromCGRect(self.parentViewController.view.bounds));
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
        self.view.backgroundColor = [assetManager darkColor];
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
    if (_detailItem != managedObject) {
        _detailItem = managedObject;
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
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [self.timeLabel setText:[dateFormatter stringFromDate:[self.detailItem valueForKey:@"start_date"]]];

        self.titleLabel.text = [self.detailItem valueForKey:@"title"];
        self.fullTitleLabel.text = [self.detailItem valueForKey:@"title"];
        
        [dateFormatter setDateFormat:@"MMM dd, yyyy h:mm a"];
        [self.dateLabel setText:[dateFormatter stringFromDate:[self.detailItem valueForKey:@"start_date"]]];
        
        self.descriptionLabel.text = [self.detailItem valueForKey:@"descrip"];

        self.scoreLabel.text = @"0 - 0";
        
        UIImage* image = nil;
        if ([self.detailItem valueForKey:@"imageURL"]) {
            NSURL* imageURL = [NSURL URLWithString:[self.detailItem valueForKey:@"imageURL"]];
            UIImage* cachedImage = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
            if (cachedImage) {
                self.cleanImageView.image = cachedImage;
            }
            else {
                [self.cleanImageView setImageWithURL:imageURL placeholderImage:image];
            }
        }
        else {
            self.cleanImageView.image = image;
        }
        
        if ([self.detailItem valueForKey:@"imageURL"]) {
            NSURL* imageURL = [NSURL URLWithString:[self.detailItem valueForKey:@"blurredImageURL"]];
            UIImage* cachedImage = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
            if (cachedImage) {
                self.blurredImageView.image = cachedImage;
            }
            else {
                [self.blurredImageView setImageWithURL:imageURL placeholderImage:image];
            }
        }
        else {
            self.blurredImageView.image = image;
        }
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
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"category like %@", @"athletic"];
    
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
    
    UIImageView * thumbnail = [assetManager createThumbnailWithFrame:cell.thumbnailViewTemplate.frame imageView:[self imageViewForComment:tempComment]];
    if (cell.thumbnailView) {
        [cell.thumbnailView removeFromSuperview];
    }
    [cell addSubview:thumbnail];
    cell.thumbnailView = thumbnail;
    
    NSString * commentID = [tempComment.id stringValue];
    CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
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

-(BOOL)userHasLikedComment:(Comment*)comment{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger userID = [[defaults objectForKey:@"user_id"] integerValue];
    for(int i = 0; i < [comment.likes count];i++){
        if(userID==[comment.likes[i] integerValue]){
            return YES;
        }
    }return NO;
}

-(NSString*)nameLabelTextForComment:(Comment*)comment{
    NSString* text = @"Unknown";
    if(comment.peer_id){
        Peer* tempPeer = [[PAFetchManager sharedFetchManager] getPeerWithID:comment.peer_id];;
        if(tempPeer){
            text=tempPeer.name;
        }
    }
    
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"comment id: %@ my id: %@",comment.peer_id, [defaults objectForKey:@"user_id"]);
    if([[defaults objectForKey:@"user_id"] integerValue]==[comment.peer_id integerValue]){
        text = [[defaults objectForKey:@"first_name"] stringByAppendingString:@" "];
        text = [text stringByAppendingString:[defaults objectForKey:@"last_name"]];
    }
    text = [text stringByAppendingString:@" "];
    text = [text stringByAppendingString:[self dateToString:comment.created_at]];
    
    return text;
}

- (UIImageView *)imageViewForComment:(Comment*)comment {
    NSUserDefaults*defaults = [NSUserDefaults standardUserDefaults];
    NSURL* imageURL;
    if([[defaults objectForKey:@"user_id"] integerValue]==[comment.peer_id integerValue]){
        //return [[UIImageView alloc] initWithImage:self.userPicture];
        imageURL = [NSURL URLWithString:[defaults objectForKey:@"profile_picture_url"]];
    } else {
        Peer * commentFromPeer = [[PAFetchManager sharedFetchManager] getPeerWithID:comment.peer_id];
        if(commentFromPeer.imageURL){
            imageURL = [NSURL URLWithString:commentFromPeer.imageURL];
        }else{
            imageURL = nil;
        }
    }if(imageURL){
        UIImage* profPic = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:imageURL]];
        if(profPic){
            return [[UIImageView alloc] initWithImage:profPic];
        }
        else{
            UIImageView * imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:imageURL placeholderImage:[assetManager profilePlaceholder]];
            return imageView;
        }
    }
    else{
        return [[UIImageView alloc] initWithImage:[assetManager profilePlaceholder]];
    }
}


-(NSString*)dateToString:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger hour = [components hour];
    NSString * timeOfDay = @" AM";
    if(hour>12){
        hour-=12;
        timeOfDay = @" PM";
    }
    
    NSString *minute = [@([components minute]) stringValue];
    if(minute.length==1){
        minute = [@"0" stringByAppendingString:minute];
    }
    
    NSString * dateString = [[@(hour) stringValue] stringByAppendingString:@":"];
    dateString = [dateString stringByAppendingString:minute];
    dateString = [dateString stringByAppendingString:timeOfDay];
    return dateString;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] < [_fetchedResultsController.fetchedObjects count]){
        Comment *comment = _fetchedResultsController.fetchedObjects[[indexPath row]];
        NSString * commentID = [comment.id stringValue];
        CGFloat height = [[heightDictionary valueForKey:commentID] floatValue];
        if(height){
            return height;
        }
    }
    return defaultCellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //self.keyboardAccessoryView.frame = CGRectMake(0, scrollView.contentOffset.y + self.view.frame.size.height - self.keyboardAccessoryView.frame.size.height, self.keyboardAccessoryView.frame.size.width, self.keyboardAccessoryView.frame.size.height);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /*
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
     PACommentCell *cell = (PACommentCell*)[self.tableView cellForRowAtIndexPath:indexPath];
     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
     [cell.commentTextView resignFirstResponder];
     */
    [self.keyboardAccessory resignFirstResponder];
}

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
    textViewHelper.frame = cell.commentTextView.frame;
    textViewHelper.text = cell.commentTextView.text;
    
    [textViewHelper setFont:[UIFont systemFontOfSize:14]];
    [textViewHelper sizeToFit];
    
    float newHeight = textViewHelper.frame.size.height;
    NSLog(@"new height: %f", newHeight);
    NSNumber *height = [NSNumber numberWithFloat: defaultCellHeight];
    if(textViewHelper.frame.size.height + textViewHelper.frame.origin.y > defaultCellHeight){
        height = [NSNumber numberWithFloat:textViewHelper.frame.size.height + textViewHelper.frame.origin.y];
    }
    //Comment* comment = _fetchedResultsController.fetchedObjects[cell.tag];
    
    NSString * commentID = [cell.commentID stringValue];
    
    [heightDictionary setValue:height forKey:commentID];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)compressTableViewCell:(PACommentCell *)cell{
    
    //cell.commentTextView.frame = CGRectMake(cell.commentTextView.frame.origin.x, cell.commentTextView.frame.origin.y, cell.commentTextView.frame.size.width, defaultCellHeight);
    //Comment *comment = _fetchedResultsController.fetchedObjects[cell.tag];
    NSString *commentID = [cell.commentID stringValue];
    [heightDictionary removeObjectForKey:commentID];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)postComment:(NSString *) text
{
    
    if(![text isEqualToString:@""]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"authentication_token"]){
            if([[defaults objectForKey:@"institution_id"] integerValue]==[[defaults objectForKey:@"home_institution"]integerValue]){
                self.commentText=nil;
                /*
                 NSIndexPath* firstCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:firstCellIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                 */
                
                NSLog(@"post comment");
                //NSString *commentText = cell.commentTextView.text;
                //cell.commentTextView.text=@"";
                
                NSNumber *userID = [defaults objectForKey:@"user_id"];
                NSNumber *institutionID = [defaults objectForKey:@"institution_id"];
                
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            text, @"content",
                                            userID, @"user_id",
                                            @"athletic", @"category",
                                            [self.detailItem valueForKey:@"id" ],@"comment_from",
                                            institutionID, @"institution_id",
                                            nil];
                
                [[PASyncManager globalSyncManager] postComment:dictionary];
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Foreign Institution" message:@"Please switch to your home institution to post comments" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
        }else{
            [[PAMethodManager sharedMethodManager] showRegisterAlert:@"post a comment" forViewController:self];
        }
        
    }
}


- (IBAction)attendButton:(id)sender {
    if([self.attendButton.titleLabel.text isEqualToString:@"Attend"]){
        
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:@"authentication_token"]){
            NSLog(@"attend the event");
            NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [defaults objectForKey:@"user_id"],@"user_id",
                                      [defaults objectForKey:@"institution_id"],@"institution_id",
                                      [self.detailItem valueForKey:@"id"],@"event_attended",
                                      @"athletic", @"category",
                                      [defaults objectForKey:@"user_id"], @"added_by",
                                      nil];
            
            [[PASyncManager globalSyncManager] attendEvent:attendee forViewController:self];
        }else{
            [[PAMethodManager sharedMethodManager] showRegisterAlert:@"attend an event" forViewController:self];
        }
    }else{
        NSLog(@"unattend the event");
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary* attendee = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self.detailItem valueForKey:@"id"], @"event_attended",
                                  [defaults objectForKey:@"institution_id"],@"institution_id",
                                  [defaults objectForKey:@"user_id"],@"user_id",
                                  @"athletic", @"category",
                                  nil];
        
        [[PASyncManager globalSyncManager] unattendEvent: attendee forViewController:self];
        
    }
    
}

#pragma mark - Text Fields

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)keyboardWasHidden:(NSNotification*)notification
{
    
    NSLog(@"after the keyboard was hidden, the y is %f", self.keyboardAccessoryView.frame.origin.y);
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"keyboard will show");
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardAccessoryView.frame = CGRectOffset(self.keyboardAccessoryView.frame, 0, -keyboardSize.height);
    self.keyboardAccessory.frame = CGRectMake(7, 7, self.view.frame.size.width - self.postButton.frame.size.width - 7, 30);
    self.postButton.alpha = 1;
    
    [UIView commitAnimations];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.keyboardAccessoryView.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.keyboardAccessory.frame = CGRectInset(self.keyboardAccessoryView.bounds, 7, 7);
    self.postButton.alpha = 0;
    
    NSLog(@"height of the view %f", self.view.frame.size.height);
    NSLog(@"keyboard y %f", self.keyboardAccessoryView.frame.origin.y);
    
    NSLog(@"actual keyboard frame %@", NSStringFromCGRect(self.keyboardAccessory.frame));
    
    [UIView commitAnimations];
}

- (BOOL)textViewIsSmallerThanFrame:(NSString*)text{
    textViewHelper.frame = CGRectMake(0, 0, 222, 0);
    [textViewHelper setFont:[UIFont systemFontOfSize:14]];
    [textViewHelper setHidden:YES];
    textViewHelper.text = text;
    [textViewHelper sizeToFit];
    if(textViewHelper.frame.size.height>defaultCellHeight){
        return NO;
    }
    return YES;
}

- (void)didSelectPostButton:(id)sender
{
    [self postComment:self.keyboardAccessory.text];
    [self.keyboardAccessory resignFirstResponder];
    self.keyboardAccessory.text = @"";
}

@end
