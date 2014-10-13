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

@class PACommentCell;

@interface PANestedInfoViewController : UIViewController <PANestedCellControllerProtocol>

// the NSManagedObject that defined the attributes of this cell. usually passed by fetched results controller
@property (strong, nonatomic) id detailItem;

// the UITableViewCell in the parent that contains this cell. useful for laying out the compressed view
@property (weak, nonatomic) UITableViewCell *containingCell;

// configures the view based on the assigned detail item of the cell
- (void)configureView;

// expand and compress the views
- (void)expandTableViewCell:(PACommentCell *)cell;
- (void)compressTableViewCell:(PACommentCell *)cell;
- (void)reloadAttendeeLabels;

// post a comment to the webservice
-(void)postComment:(NSString *)text withCategory:(NSString*)category;

@property (strong, nonatomic) NSString* commentText;

@property (strong, nonatomic) NSString* category;

@end
