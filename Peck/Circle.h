//
//  Circle.h
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Circle : NSManagedObject

@property (nonatomic, retain) NSString * circleName;
@property (nonatomic, retain) id members;
@property (nonatomic, retain) NSNumber * numberOfMembers;

@end
