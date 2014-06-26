//
//  PeckWebserviceTests.m
//  Peck
//
//  Created by Aaron Taylor on 6/26/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PASessionManager.h"

@interface PeckWebserviceTests : XCTestCase

@end

@implementation PeckWebserviceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)SSLTesting
{
    [[PASessionManager sharedSecureClient] GET:@"api/simple_events"
                                    parameters:nil
                                       success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"JSON: %@",JSON);
         NSArray *postsFromResponse = (NSArray*)JSON;
         
         XCTAssert(postsFromResponse.count > 0, @"non-empty repsonse for events");

     }
                                       failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                           NSLog(@"ERROR: %@",error);
                                           XCTFail(@"error in secure sercer communication");
                                       }];
}

@end
