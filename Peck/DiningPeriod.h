//
//  DiningPeriod.h
//  Peck
//
//  Created by John Karabinos on 7/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiningPeriod : NSManagedObject

@property (nonatomic, retain) NSNumber * day_of_week;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * opportunity_id;
@property (nonatomic, retain) NSNumber * place_id;
@property (nonatomic, retain) NSDate * start_date;

@end
