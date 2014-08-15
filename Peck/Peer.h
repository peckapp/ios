//
//  Peer.h
//  Peck
//
//  Created by John Karabinos on 8/15/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Circle;

@interface Peer : NSManagedObject

@property (nonatomic, retain) NSString * blurb;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * home_institution;
@property (nonatomic, retain) NSSet *circles;
@end

@interface Peer (CoreDataGeneratedAccessors)

- (void)addCirclesObject:(Circle *)value;
- (void)removeCirclesObject:(Circle *)value;
- (void)addCircles:(NSSet *)values;
- (void)removeCircles:(NSSet *)values;

@end
