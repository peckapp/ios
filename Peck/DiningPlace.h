//
//  DiningPlace.h
//  Peck
//
//  Created by Aaron Taylor on 10/12/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiningPlace : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) id dining_opportunities;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * blurredImageURL;

@end
