//
//  Message.h
//  Peck
//
//  Created by John Karabinos on 6/18/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * text;

@end
