//
//  DiningPeriod.h
//  Peck
//
//  Created by John Karabinos on 7/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiningPlace, Event;

@interface DiningPeriod : NSManagedObject

@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * opportunity_id;
@property (nonatomic, retain) NSNumber * place_id;
@property (nonatomic, retain) NSSet *dining_opportunity;
@property (nonatomic, retain) NSSet *dining_place;
@end

@interface DiningPeriod (CoreDataGeneratedAccessors)

- (void)addDining_opportunityObject:(Event *)value;
- (void)removeDining_opportunityObject:(Event *)value;
- (void)addDining_opportunity:(NSSet *)values;
- (void)removeDining_opportunity:(NSSet *)values;

- (void)addDining_placeObject:(DiningPlace *)value;
- (void)removeDining_placeObject:(DiningPlace *)value;
- (void)addDining_place:(NSSet *)values;
- (void)removeDining_place:(NSSet *)values;

@end
