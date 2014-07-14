//
//  Circle.h
//  Peck
//
//  Created by John Karabinos on 7/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Peer;

@interface Circle : NSManagedObject

@property (nonatomic, retain) NSString * circleName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * numberOfMembers;
@property (nonatomic, retain) NSSet *circle_members;
@end

@interface Circle (CoreDataGeneratedAccessors)

- (void)addCircle_membersObject:(Peer *)value;
- (void)removeCircle_membersObject:(Peer *)value;
- (void)addCircle_members:(NSSet *)values;
- (void)removeCircle_members:(NSSet *)values;

@end
