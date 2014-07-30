//
//  PACreateCircleViewController.h
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTAutocompleteManager.h"
#import "Peer.h"

@class PACircleViewController;
@protocol PACirclePeersControllerDelegate <NSObject>

-(void)removePeer: (int) peer;
@end

@interface PACreateCircleViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate,PACirclePeersControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

- (IBAction)createCircleButton:(id)sender;
- (IBAction)cancelCreateCircle:(id)sender;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet HTAutocompleteTextField *membersAutocompleteTextField;
@property (strong, nonatomic) NSMutableArray *addedPeers;



@end
