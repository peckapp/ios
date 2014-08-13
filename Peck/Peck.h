//
//  Peck.h
//  Peck
//
//  Created by John Karabinos on 8/13/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Peck : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * institution_id;
@property (nonatomic, retain) NSNumber * interacted_with;
@property (nonatomic, retain) NSNumber * invitation_id;
@property (nonatomic, retain) NSNumber * invited_by;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * notification_type;
@property (nonatomic, retain) NSNumber * refers_to;

@end
