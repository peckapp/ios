//
//  PADiningOpportunityViewController.h
//  Peck
//
//  Created by Jonas Luebbers on 8/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"
#import "PANestedTableViewCell.h"
#import "PACommentCell.h"

@interface PADiningOpportunityViewController : UIViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PANestedTableViewCellSubviewControllerProtocol>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
