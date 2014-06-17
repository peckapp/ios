//
//  PADetailViewController.h
//  Peck
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PACoreDataProtocol.h"


@interface PAEventInfoViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic) IBOutlet UIImageView *eventPhoto;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;

@end
