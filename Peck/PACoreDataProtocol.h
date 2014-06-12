//
//  PACoreDataProtocol.h
//  Peck
//
//  Created by Aaron Taylor on 6/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

// these are hopefully temporary macros to access the main storyboard's childviewcontrollers of the dropdown
#define PASeguePecksIdentifier @"pecks"
#define PASegueFeedIdentifier @"feed"
#define PASegueAddIdentifier @"add"
#define PASegueCirclesIdentifier @"circles"
#define PASegueProfileIdentifier @"profile"


@protocol PACoreDataProtocol

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
