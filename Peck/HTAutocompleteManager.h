//
//  HTAutocompleteManager.h
//  HotelTonight
//
//  Created by Jonathan Sibley on 12/6/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTAutocompleteTextField.h"
#import "PACreateCircleViewController.h"
#import "Peer.h"

typedef enum {
    HTAutocompleteTypeEmail, // Default
    HTAutocompleteTypeColor,
    HTAutocompleteTypeName,
} HTAutocompleteType;


@interface HTAutocompleteManager : NSObject <HTAutocompleteDataSource>

+ (HTAutocompleteManager *)sharedManager;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property Peer *currentPeer;
@property NSMutableArray* suggestedPeers;

@end