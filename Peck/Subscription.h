//
//  Subscription.h
//  Peck
//
//  Created by John Karabinos on 7/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Subscription : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * subscribed;

@end
