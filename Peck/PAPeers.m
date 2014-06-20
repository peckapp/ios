//
//  PAPeers.m
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAPeers.h"
#import "PABST.h"
@interface PAPeers(){
    
}

@end

@implementation PAPeers{

}

+ (instancetype)peers {
    static PAPeers *_peers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _peers = [[PAPeers alloc] init];
    });
    
    return _peers;
}

-(id)init{
    
    NSArray *testPeers = @[@"John",@"Mark",@"Jason",@"Andrew", @"Jenny"];
    
    self.peerTree = [[PABST alloc] init];
    
    for(int i=0; i<[testPeers count]; i++){
        [self.peerTree addNode:self.peerTree WithName:testPeers[i]];
    }
    
    return self;
}


@end
