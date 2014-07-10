//
//  DiningPlace.h
//  Peck
//
//  Created by John Karabinos on 7/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface DiningPlace : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) id dining_opportunities;
@property (nonatomic, retain) NSSet *dining_opportunity;
@end

@interface DiningPlace (CoreDataGeneratedAccessors)

- (void)addDining_opportunityObject:(Event *)value;
- (void)removeDining_opportunityObject:(Event *)value;
- (void)addDining_opportunity:(NSSet *)values;
- (void)removeDining_opportunity:(NSSet *)values;

@end
