//
//  Event.h
//  Peck
//
//  Created by John Karabinos on 6/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * descrip;
@property (nonatomic, retain) id members;
@property (nonatomic, retain) NSString * time;

@end
