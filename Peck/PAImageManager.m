//
//  PAImageManager.m
//  Peck
//
//  Created by John Karabinos on 6/24/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PAImageManager.h"

@implementation PAImageManager


+ (instancetype)imageManager {
    static PAImageManager *_imageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageManager = [[PAImageManager alloc] init];
    });
    
    return _imageManager;
}


-(void)WriteImage:(NSData*)imageData WithTitle:(NSString *)title{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *imageName = [title stringByAppendingString:@".png"];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName]; //Add the file name
    [imageData writeToFile:filePath atomically:YES]; //Write the file

}

-(NSData *)ReadImage:(NSString *)title{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *imageName = [title stringByAppendingString:@".png"];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    return pngData;
}

@end
