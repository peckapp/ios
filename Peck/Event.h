//
//  Event.h
//  Peck
//
//  Created by John Karabinos on 7/10/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DiningPeriod, DiningPlace;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * descrip;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) id members;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *dining_place;
@property (nonatomic, retain) NSSet *dining_period;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addDining_placeObject:(DiningPlace *)value;
- (void)removeDining_placeObject:(DiningPlace *)value;
- (void)addDining_place:(NSSet *)values;
- (void)removeDining_place:(NSSet *)values;

- (void)addDining_periodObject:(DiningPeriod *)value;
- (void)removeDining_periodObject:(DiningPeriod *)value;
- (void)addDining_period:(NSSet *)values;
- (void)removeDining_period:(NSSet *)values;

@end
