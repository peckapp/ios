//
//  Institution.h
//  Peck
//
//  Created by Aaron Taylor on 7/1/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Institution : NSManagedObject

@property (nonatomic,retain) NSNumber * id;
@property (nonatomic,retain) NSString * name;
@property (nonatomic,retain) NSString * street_address;
@property (nonatomic,retain) NSString * city;
@property (nonatomic,retain) NSString * country;
@property (nonatomic,retain) NSNumber * gps_latitude;
@property (nonatomic,retain) NSNumber * gps_longitude;
@property (nonatomic,retain) NSNumber * range;
@property (nonatomic,retain) NSDate * created_at;
@property (nonatomic,retain) NSDate * updated_at;

@end
