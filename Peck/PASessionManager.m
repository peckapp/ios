//
//  PASessionManager.m
//  Peck
//
//  Created by Aaron Taylor on 6/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASessionManager.h"


static NSString * const PALocalAPIBaseURLString = @"http://localhost:3000/";
// Development webservice
static NSString * const PARailsServerBaseURLString = @"http://loki.peckapp.com:3000/"; // must be manually running from command line on the server
static NSString * const PADevAPIBaseURLString = @"http://loki.peckapp.com:3500/";
// Production Webservice - both https
static NSString * const PAStagingAPIBaseURLString = @"https://buri.peckapp.com:3500/";
static NSString * const PAProdAPIBaseURLString = @"https://yggdrasil.peckapp.com:3500/";

@implementation PASessionManager

+ (instancetype)sharedClient {
    static PASessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PASessionManager alloc] initWithBaseURL:[NSURL URLWithString:PALocalAPIBaseURLString]];
        
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    });
    
    return _sharedClient;
}

+ (instancetype)sharedSecureClient {
    static PASessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PASessionManager alloc] initWithBaseURL:[NSURL URLWithString:PAProdAPIBaseURLString]];
        
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        // TODO: must remove this for production once our certificates for the webservice are created
        _sharedClient.securityPolicy.allowInvalidCertificates = YES;
        
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    });
    
    return _sharedClient;
}

@end
