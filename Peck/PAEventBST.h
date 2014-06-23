//
//  PAEventBST.h
//  Peck
//
//  Created by John Karabinos on 6/23/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"


@interface PAEventBST : NSObject

@property (strong, nonatomic) NSString *name;

-(void)addNode:(PAEventBST*)root WithName:newName WithEvent:newEvent;
-(BOOL)search:(NSString *)searchName;
-(NSMutableArray*)searchForName:(NSString *)searchName WithArray:currentNames;

@property PAEventBST *right;
@property PAEventBST *left;
@property Event * event;
@end
