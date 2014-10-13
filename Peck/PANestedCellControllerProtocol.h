//
//  PANestedCellControllerProtocol.h
//  Peck
//
//  Created by Aaron Taylor on 10/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

@protocol PANestedCellControllerProtocol

@required

- (void) setManagedObject:(NSManagedObject *)managedObject parentObject:(NSManagedObject *)parentObject;
- (void)expandAnimated:(BOOL)animated;
- (void)compressAnimated:(BOOL)animated;
- (UIView *)viewForBackButton;

@end

