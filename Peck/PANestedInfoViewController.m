//
//  PANestedInfoViewController.m
//  
//
//  Created by Aaron Taylor on 10/12/14.
//
//

#import "PANestedInfoViewController.h"
#import "PANestedInfoViewControllerPrivate.h"

@implementation PANestedInfoViewController

-(void)viewDidLoad {
    self.attendImage = [UIImage imageNamed:@"attend_icon"];
    self.nullAttendImage = [UIImage imageNamed:@"null_attend_icon"];
}

-(void) configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    abort();
}

-(void)setManagedObject:(NSManagedObject *)managedObject parentObject:(NSManagedObject *)parentObject {
    abort();
}

-(void)compressAnimated:(BOOL)animated {
    abort();
}

-(void)expandAnimated:(BOOL)animated {
    abort();
}

-(UIView*) viewForBackButton {
    return nil;
}

@end
