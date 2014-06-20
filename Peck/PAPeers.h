//
//  PAPeers.h
//  Peck
//
//  Created by John Karabinos on 6/20/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PABST.h"

@interface PAPeers : NSObject
+(instancetype)peers;
@property (atomic, retain) PABST * peerTree;
@end
