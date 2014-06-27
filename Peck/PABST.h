//
//  PABST.h
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface PABST : NSObject

@property (strong, nonatomic) NSString *name;

-(void)addNode:(PABST*)root withPeer:newPeer;
-(BOOL)search:(NSString *)searchName;
-(NSMutableArray*)searchForName:(NSString *)searchName WithArray:currentNames;

@property PABST *right;
@property PABST *left;
@property Peer *peer;
@end
