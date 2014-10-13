//
//  PANestedInfoViewController.h
//  
//
//  Created by Aaron Taylor on 10/12/14.
//
//

#import <UIKit/UIKit.h>

#import "PACoreDataProtocol.h"
#import "PANestedCellControllerProtocol.h"

@interface PANestedInfoViewController : UIViewController <PANestedCellControllerProtocol>

// the NSManagedObject that defined the attributes of this cell. usually passed by fetched results controller
@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) UITableViewCell *containingCell;

@end
