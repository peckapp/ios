//
//  PADiningPlacesTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/9/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PADiningPlacesTableViewController : UITableViewController <PACoreDataProtocol>


@property (strong, nonatomic) id detailItem;

@end
