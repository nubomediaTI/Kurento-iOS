//
//  KurentoToolboxTests.m
//  KurentoToolboxTests
//
//  Created by Marco Rossi on 06/11/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KurentoToolbox.h"

@interface KurentoToolboxTests : XCTestCase <NBMJSONRPCClientDelegate>

@end

@implementation KurentoToolboxTests

- (void)setUp {
    [super setUp];
    NBMJSONRPCClient *client = [[NBMJSONRPCClient alloc] initWithURL:[NSURL URLWithString:@"http://"]];
    client.delegate = self;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)client:(NBMJSONRPCClient *)client didFailWithError:(NSError *)error {
    
}

- (void)client:(NBMJSONRPCClient *)client didReceiveRequest:(NBMRequest *)request {
    
}

@end
