//
//  Explore.h
//  Peck
//
//  Created by John Karabinos on 7/30/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Explore : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSString * explore_description;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) id members;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * imageURL;

@end
