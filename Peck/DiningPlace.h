//
//  DiningPlace.h
//  Peck
//
//  Created by John Karabinos on 7/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiningPeriod, Event;

@interface DiningPlace : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) id dining_opportunities;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSSet *dining_opportunity;
@property (nonatomic, retain) NSSet *dining_period;
@end

@interface DiningPlace (CoreDataGeneratedAccessors)

- (void)addDining_opportunityObject:(Event *)value;
- (void)removeDining_opportunityObject:(Event *)value;
- (void)addDining_opportunity:(NSSet *)values;
- (void)removeDining_opportunity:(NSSet *)values;

- (void)addDining_periodObject:(DiningPeriod *)value;
- (void)removeDining_periodObject:(DiningPeriod *)value;
- (void)addDining_period:(NSSet *)values;
- (void)removeDining_period:(NSSet *)values;

@end
