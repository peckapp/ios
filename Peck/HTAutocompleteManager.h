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

@property Peer *currentPeer;

@end