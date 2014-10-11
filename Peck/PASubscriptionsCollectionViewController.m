//
//  PASubscriptionsCollectionViewController.m
//  Peck
//
//  Created by Aaron Taylor on 9/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//
// uses implementation from: https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController

#import "PASubscriptionsCollectionViewController.h"
#import "PASubscriptionsCollectionCell.h"
#import "Subscription.h"
#import "PAAppDelegate.h"
#import "UICollectionView+NSFetchedResultsController.h"
#import "UIImageView+AFNetworking.h"

static NSString *CellIdentifier = @"SubscriptionsCollectionViewCell";

@interface PASubscriptionsCollectionViewController ()

@property (strong, nonatomic) NSBlockOperation * blockOperation;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;

-(IBAction)finishInitialSelections:(id)sender;

@end

@implementation PASubscriptionsCollectionViewController {
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (self.isInitializing == YES) {
        self.finishButton.enabled = true;
        self.finishButton.title = @"Finish";
    } else {
        self.isInitializing = NO;
        self.finishButton.enabled = false;
        self.finishButton.title = @"";
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PASubscriptionsCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    NSError *err = nil;
    [[self fetchedResultsController] performFetch:&err];
    if (err) {
        NSLog(@"error performing subscriptions fetch: %@",err);
        abort();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)finishInitialSelections:(id)sender {
    if (self.isInitializing) {
        PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
        [appDelegate.window setRootViewController:newRoot];
    }
    
}

#pragma mark - data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger count = [[self.fetchedResultsController sections] count];
    return count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PASubscriptionsCollectionCell *cell = (PASubscriptionsCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Subscription *sub = (Subscription*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self configureCell:cell withObject:sub];
    
    return cell;
}

-(void)configureCell:(PASubscriptionsCollectionCell*)subscriptionCell withObject:(Subscription*)subscription {
    subscriptionCell.subscription = subscription;
    UILabel * cellTitle = subscriptionCell.subscriptionTitle;
    cellTitle.text = subscription.name;
    cellTitle.textColor = [UIColor darkTextColor];
    
    subscriptionCell.parentViewController = self;
    
    subscriptionCell.imageView.frame = subscriptionCell.layer.frame;
    [subscriptionCell.imageView setImageWithURL:[NSURL URLWithString:subscription.imageURL]];
    
    BOOL subscribed = [subscription.subscribed boolValue];
    if(subscribed) {
        subscriptionCell.subscriptionSwitch.on = YES;
    } else {
        subscriptionCell.subscriptionSwitch.on = NO;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat dim = (self.view.frame.size.width / 2.0) - 10.0;
    return CGSizeMake(dim, dim);
}

#pragma mark - delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGFloat dim = (self.view.frame.size.width / 2.0) - 40.0;
    return CGSizeMake(dim, dim);
}

#pragma mark - fetched results controller

-(NSFetchedResultsController *)fetchedResultsController{
    //NSLog(@"Returning the normal controller");
    if(_fetchedResultsController!=nil){
        return _fetchedResultsController;
    }
    PAAppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appdelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    
    NSString * subscriptionString = @"Subscription";
    NSEntityDescription *entity = [NSEntityDescription entityForName:subscriptionString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort keys as appropriate.
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES],
                                 [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:_managedObjectContext
                                                                            sectionNameKeyPath:@"category"
                                                                                     cacheName:nil];
    frc.delegate = self;
    self.fetchedResultsController = frc;
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    [self.collectionView addChangeForSection:sectionInfo atIndex:sectionIndex forChangeType:type];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    [self.collectionView addChangeForObjectAtIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.collectionView commitChanges];
}

@end
