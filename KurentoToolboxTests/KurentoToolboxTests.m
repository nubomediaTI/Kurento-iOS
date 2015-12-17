//
//  KurentoToolboxTests.m
//  KurentoToolboxTests
//
//  Created by Marco Rossi on 06/11/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KurentoToolbox.h"

@interface KurentoToolboxTests : XCTestCase <NBMJSONRPCClientDelegate, NBMWebRTCPeerDelegate>

@property (nonatomic, strong) NBMJSONRPCClient *client;
@property (nonatomic, strong) NBMWebRTCPeer *peer;

@end

@implementation KurentoToolboxTests

- (void)setUp {
    [super setUp];
    NBMJSONRPCClient *client = [[NBMJSONRPCClient alloc] initWithURL:[NSURL URLWithString:@"http://"] delegate:self];
    self.client = client;
    NBMWebRTCPeer *peer = [[NBMWebRTCPeer alloc] initWithDelegate:self configuration:nil];
    self.peer = peer;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    NBMRequest *req = [NBMRequest requestWithMethod:@"method" parameters:@{}];
//    [self.client sendRequest:req completion:^(NBMResponse *response) {
//        DDLogDebug(@"%@", response);
//    }];
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

- (void)clientDidConnect:(NBMJSONRPCClient *)client {
    
}

- (void)clientDidDisconnect:(NBMJSONRPCClient *)client {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateAnswer:(RTCSessionDescription *)sdpAnswer forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateOffer:(RTCSessionDescription *)sdpOffer forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didRemoveStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCICEConnectionState)state ofConnection:(NBMPeerConnection *)connection {
    
}

@end
