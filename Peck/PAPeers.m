//
//  PAPeers.m
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPeers.h"

@implementation PAPeers



+ (instancetype)peers {
    static PAPeers *_peers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _peers = [[PAPeers alloc] init];
    });
    
    return _peers;
}

-(id)init{
    self;
    
    return self;
}


@end
