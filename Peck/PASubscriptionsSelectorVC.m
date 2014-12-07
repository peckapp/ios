//
//  AFMasterViewController.m
//  UICollectionViewExample
//
//  Created by Ash Furrow on 2012-09-11.
//  Copyright (c) 2012 Ash Furrow. All rights reserved.
//

#import "PASubscriptionsSelectorVC.h"
#import "PASubscriptionsCollectionCell.h"

#import "PAAppDelegate.h"
#import "PAAssetManager.h"
#import "PASyncManager.h"
#import "PASubscriptionsHeader.h"

#import "UIImageView+AFNetworking.h"

#define MAX_CELL_HEIGHT 80
#define MARGIN_SIZE 5

static NSString *CellIdentifier = @"SubCell";

@interface PASubscriptionsSelectorVC ()

// accessed by the cells when they are modified to keep track of changes to be sent to the webservice
@property (strong, nonatomic) NSMutableDictionary* addedSubscriptions;
@property (strong, nonatomic) NSMutableDictionary* deletedSubscriptions;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;

-(IBAction)finishInitialSelections:(id)sender;

@end

@implementation PASubscriptionsSelectorVC
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
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
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    self.addedSubscriptions = [NSMutableDictionary dictionary];
    self.deletedSubscriptions = [NSMutableDictionary dictionary];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 10, 20, 10);
    
    if (self.managedObjectContext == nil) {
        PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // updates the webservice with the subscription changes when the view disappears
    if([[self.addedSubscriptions allValues] count]>0){
        [[PASyncManager globalSyncManager] postSubscriptions:[self.addedSubscriptions allValues]];
    }
    if([[self.deletedSubscriptions allValues] count]>0){
        [[PASyncManager globalSyncManager] deleteSubscriptions:[self.deletedSubscriptions allValues]];
    }
    
//    NSError *err = nil;
//    [self.managedObjectContext save:&err];
//    if (err) {
//        NSLog(@"Subscriptions save ERROR: %@",err);
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)finishInitialSelections:(id)sender {
    if (self.isInitializing) {
        // checks that the user has selected available subscriptions
        if ([self.addedSubscriptions count] > 5) {
            PAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            UIViewController * newRoot = [appDelegate.mainStoryboard instantiateInitialViewController];
            [appDelegate.window setRootViewController:newRoot];
        } else {
            UIAlertController *alertController;
            if (self.fetchedResultsController.fetchedObjects.count > 0) {
                alertController = [UIAlertController alertControllerWithTitle:@"Too Few Subscriptions"
                                                                                         message:@"Without subscriptions, your homepage will not contain any events. Select a few more!"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
            } else {
                // alertController = [UIAlertController alertControllerWithTitle:@"Subscriptions are Loading" message:@"Please wait and select at least five subscriptions to continue." preferredStyle:UIAlertControllerStyleAlert];
                return;
            }
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 
                                                             }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"finishInitialSelections was called while the viewController was not initializing"
                                     userInfo:nil];
    }
}

#pragma mark - UICollectionVIew

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PASubscriptionsCollectionCell *cell = (PASubscriptionsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Subscription *subscription = (Subscription*)[self.fetchedResultsController objectAtIndexPath:indexPath];

    [self configureCell:cell withObject:subscription];
    
    return (UICollectionViewCell*)cell;
}

-(void)configureCell:(PASubscriptionsCollectionCell*)subscriptionCell withObject:(Subscription*)subscription {
    subscriptionCell.subscriptionTitle.text = subscription.name;
    [subscriptionCell.subscriptionTitle setPreferredMaxLayoutWidth:self.view.frame.size.width/2 - 20];
    
    //NSURL *imageURL = [NSURL URLWithString:subscription.imageURL];
    //[subscriptionCell.iconImage setImageWithURL:imageURL placeholderImage:[[PAAssetManager sharedManager] subscriptionPlaceholder]];
    
    subscriptionCell.backgroundColor = [[PAAssetManager sharedManager] darkColor];
    subscriptionCell.selectedBackgroundView = [[UIView alloc] initWithFrame:subscriptionCell.frame];
    subscriptionCell.selectedBackgroundView.backgroundColor = [[PAAssetManager sharedManager] lightColor];
    if ([subscription.subscribed boolValue]) {
        [subscriptionCell setSelected:YES];
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        PASubscriptionsHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SubscriptionHeader" forIndexPath:indexPath];
        headerView.sectionTitle.text = [[[[[self fetchedResultsController] sections]objectAtIndex:indexPath.section] name] capitalizedString];
        [headerView.image setImage:[[PAAssetManager sharedManager] subscriptionPlaceholder]];
        reusableview = headerView;
    }
    
    return reusableview;
}

// returns the size of the specified element
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Subscription *sub = (Subscription*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat maxWidth = (self.view.frame.size.width / 3.0) - 10;
    CGSize maxSize = CGSizeMake(maxWidth + 2*self.view.layoutMargins.right, MAX_CELL_HEIGHT);
    CGRect textRect = [sub.name boundingRectWithSize:maxSize
                                             options:NSStringDrawingUsesFontLeading
                                          attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                             context:[[NSStringDrawingContext alloc] init]];
    return CGRectInset(textRect,-2*MARGIN_SIZE,-MARGIN_SIZE).size;
}

// returns the spacing between items
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3*MARGIN_SIZE;
}

// returns spacing between lines in a section
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3*MARGIN_SIZE;
}

// returns the spacing between different sections of the collectionview
- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView
                         layout:(UICollectionViewLayout *)collectionViewLayout
         insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}

# pragma mark delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Subscription *sub = (Subscription*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self switchSubscription:sub withCell:(PASubscriptionsCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath]];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    Subscription *sub = (Subscription*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self switchSubscription:sub withCell:(PASubscriptionsCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath]];

}

- (void)switchSubscription:(Subscription*)subscription withCell:(PASubscriptionsCollectionCell*)cell {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* institutionID = [defaults objectForKey:@"institution_id"];
    NSNumber* userID = [defaults objectForKey:@"user_id"];
    
    NSString* subKey = [subscription.category stringByAppendingString:[subscription.id stringValue]];
    
    if ([subscription.subscribed boolValue]) { // user is subscribed, remove subscription
        //NSLog(@"remove subscription");
        subscription.subscribed = [NSNumber numberWithBool:NO];
        if(![self.addedSubscriptions objectForKey:subKey]){
            //if the subscription is not on the list to be added
            [self.deletedSubscriptions setObject:subscription.subscription_id forKey:subKey];
            [cell setBackgroundColor:[[PAAssetManager sharedManager] lightColor]];
        }else{
            [self.addedSubscriptions removeObjectForKey:subKey];
            [cell setBackgroundColor:[[PAAssetManager sharedManager] darkColor]];
        }
    } else { // user is not subscribed, subscribe them
        subscription.subscribed = [NSNumber numberWithBool:YES];
        
        if(![self.deletedSubscriptions objectForKey:subKey]){
            //if the subscription is not on the list to be deleted
            NSDictionary* subscriptionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    subscription.id, @"subscribed_to",
                                                    institutionID, @"institution_id",
                                                    userID, @"user_id",
                                                    subscription.category, @"category",
                                                    nil];
            
            [self.addedSubscriptions setObject:subscriptionDictionary forKey:subKey];
            [cell setBackgroundColor:[[PAAssetManager sharedManager] lightColor]];
        }else{
            [self.deletedSubscriptions removeObjectForKey:subKey];
            [cell setBackgroundColor:[[PAAssetManager sharedManager] darkColor]];
        }
    }
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription"inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES],
                                 [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {

            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }

    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

@end
