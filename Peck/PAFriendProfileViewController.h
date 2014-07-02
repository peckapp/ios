//
//  PAFriendProfileViewController.h
//  Peck
//
//  Created by John Karabinos on 6/16/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
@interface PAFriendProfileViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextView *blurbTextView;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) id detailItem;
- (void)setDetailItem:(id)newDetailItem;
@end
