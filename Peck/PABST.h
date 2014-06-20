//
//  PABST.h
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PABST : NSObject

@property (strong, nonatomic) NSString *name;

-(void)addNode:(PABST*)root WithName:newName;
-(BOOL)search:(NSString *)searchName;
-(int)searchForName:(NSString *)searchName;

@property PABST *right;
@property PABST *left;

@end
