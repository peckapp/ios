//
//  Event.h
//  Peck
//
//  Created by John Karabinos on 8/19/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) id attendees;
@property (nonatomic, retain) NSString * blurredImageURL;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * created_by;
@property (nonatomic, retain) NSString * descrip;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) id members;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * opportunity_id;

@end
