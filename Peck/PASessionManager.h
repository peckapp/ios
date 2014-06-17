//
//  PASessionManager.h
//  Peck
//
//  Created by Aaron Taylor on 6/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface PASessionManager : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
