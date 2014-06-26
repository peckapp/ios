//
//  PeckTests.m
//  PeckTests
//
//  Created by Aaron Taylor on 5/29/14.
//  Copyright (c) 2014 Peck. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "PASessionManager.h"

@interface PeckTests : XCTestCase

@end

@implementation PeckTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)SSLTesting
{
    [[PASessionManager sharedSecureClient] GET:@"api/events"
                                    parameters:nil
                                       success:^
     (NSURLSessionDataTask * __unused task, id JSON) {
         NSLog(@"JSON: %@",JSON);
         NSArray *postsFromResponse = (NSArray*)JSON;
         for (NSDictionary *eventAttributes in postsFromResponse) {
             NSLog(@"Event Attributes: %@",eventAttributes);
         }
     }
                                 failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                     NSLog(@"ERROR: %@",error);
                                 }];
    
}

@end
