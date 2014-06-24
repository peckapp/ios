//
//  PAImageManager.h
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAImageManager : NSObject

+ (instancetype)imageManager;
-(void)WriteImage:(NSData*)imageData WithTitle:(NSString *)title;
-(NSData *)ReadImage:(NSString *)title;

@end
