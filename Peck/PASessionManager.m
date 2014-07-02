//
//  PASessionManager.m
//  Peck
//
//  Created by Aaron Taylor on 6/17/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import "PASessionManager.h"


static NSString * const PALocalAPIBaseURLString = @"http://localhost:3000/";
// extended lynda tutorial with some api features
static NSString * const PATestAPIBaseURLString = @"http://thor.peckapp.com:3200/";
static NSString * const PATestSecureAPIBaseURLString = @"https://thor.peckapp.com:3201/";
// development webservice
static NSString * const PADevAPIBaseURLString = @"http://thor.peckapp.com:3500/";
static NSString * const PADevProdAPIBaseURLString = @"http://thor.peckapp.com:3501/";
static NSString * const PADevSecureAPIBaseURLString = @"https://thor.peckapp.com:3502/";

@implementation PASessionManager

+ (instancetype)sharedClient {
    static PASessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PASessionManager alloc] initWithBaseURL:[NSURL URLWithString:PADevAPIBaseURLString]];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    
    return _sharedClient;
}

+ (instancetype)sharedSecureClient {
    static PASessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PASessionManager alloc] initWithBaseURL:[NSURL URLWithString:PADevSecureAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        // TODO: must remove this for production once our certificates for the webservice are created
        _sharedClient.securityPolicy.allowInvalidCertificates = YES;
    });
    
    return _sharedClient;
}

@end
