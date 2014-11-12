//
//  PAEventInfoTableViewController.h
//  Peck
//
//  Created by John Karabinos on 7/2/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//
//  This view controller displays the event information (start time, end time, description etc.), as well as comments.
//  The view calls a get request to reload the comments every couple of seconds while active.

#import <UIKit/UIKit.h>
#import "PANestedInfoViewController.h"

@class PACommentCell;

@interface PAAthleticEventViewController : PANestedInfoViewController <NSFetchedResultsControllerDelegate,PACoreDataProtocol,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>



@end
