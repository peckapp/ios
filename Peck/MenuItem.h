//
//  MenuItem.h
//  Peck
//
//  Created by John Karabinos on 7/14/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MenuItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * dining_place_id;
@property (nonatomic, retain) NSNumber * dining_opportunity_id;

@end
