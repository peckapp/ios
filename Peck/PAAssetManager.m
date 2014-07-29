//
//  PAAssetManager.m
//  Peck
//
//  Created by Jonas Luebbers on 7/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAAssetManager.h"

@implementation PAAssetManager

+ (id)sharedManager {
    static PAAssetManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init {
    if (self = [super init]) {

        self.horizontalShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"drop-shadow-horizontal"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
        NSLog(@"Created shadow");

    }
    return self;
}

@end
