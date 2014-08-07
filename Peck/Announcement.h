//
//  Announcement.h
//  Peck
//
//  Created by John Karabinos on 8/6/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Announcement : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) id invites;
@property (nonatomic, retain) NSNumber * id;

@end
