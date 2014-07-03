//
//  Comment.h
//  Peck
//
//  Created by John Karabinos on 7/3/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comment : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * peer_id;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * comment_from;
@property (nonatomic, retain) NSString * content;

@end
