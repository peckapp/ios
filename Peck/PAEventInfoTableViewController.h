//
//  PAEventInfoTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PACoreDataProtocol.h"

@interface PAEventInfoTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol>



@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UITextView *blurbTextView;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@end
