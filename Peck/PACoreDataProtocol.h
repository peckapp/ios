//
//  PACoreDataProtocol.h
//  Peck
//
//  Created by Aaron Taylor on 6/7/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

// these are hopefully temporary macros to access the main storyboard's childviewcontrollers of the dropdown
#define PAPecksIdentifier @"pecks"
#define PAFeedIdentifier @"feed"
#define PAAddIdentifier @"add"
#define PACirclesIdentifier @"circles"
#define PAProfileIdentifier @"profile"

#define PAPecksIndex 1
#define PAFeedIndex 2
#define PAAddIndex 3
#define PACirclesIndex 4
#define PAProfileIndex 5

@protocol PACoreDataProtocol

@required
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
