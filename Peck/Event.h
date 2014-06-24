//
//  Event.h
//  Peck
//
//  Created by John Karabinos on 6/18/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * descrip;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) id members;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * id;

@end
