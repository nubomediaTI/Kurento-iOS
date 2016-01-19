//
//  NBMTreeClient.m
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NBMTreeClient.h"
#import "NBMTreeClientDelegate.h"

#import "NBMJSONRPCClient.h"
#import "NBMJSONRPCClientDelegate.h"
#import "NBMLog.h"

#import <libjingle_peerconnection/RTCICECandidate.h>

static NSString* const kAddICECandidateMethod = @"addIceCandidate";
//static NSString* const kICECandidateEvent = @"iceCandidate";
static NSString* const kAddTreeSinkMethod = @"addTreeSink";
static NSString* const kAnswerSdp = @"answerSdp";
static NSString* const kCreateTreeMethod = @"createTree";
static NSString* const kICECandidate = @"candidate";
static NSString* const kICESdpMid = @"sdpMid";
static NSString* const kICESdpMLineIndex = @"sdpMLineIndex";
static NSString* const kOfferSdp = @"offerSdp";
static NSString* const kReleaseTreeMethod = @"releaseTree";
static NSString* const kRemoveTreeSinkMethod = @"removeTreeSink";
static NSString* const kRemoveTreeSourceMethod = @"removeTreeSource";
static NSString* const kSetTreeSourceMethod = @"setTreeSource";
static NSString* const kSinkId = @"sinkId";
static NSString* const kTreeId = @"treeId";

typedef void(^ErrorBlock)(NSError *error);

@interface NBMTreeClient () <NBMJSONRPCClientDelegate>

@property (nonatomic, strong) NSURL *wsURL;
@property (nonatomic, strong) NBMJSONRPCClient *jsonRpcClient;
@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL closeRequested;
@property (nonatomic, strong) NSError *rpcError;

@end

static NSTimeInterval kTreeClientTimeoutInterval = 5;

@implementation NBMTreeClient

#pragma mark - Initialization

- (instancetype)initWithURL:(NSURL *)wsURL delegate:(id<NBMTreeClientDelegate>)delegate {
    NSParameterAssert(wsURL);
    self = [super init];
    if (self) {
        _wsURL = wsURL;
        _delegate = delegate;
    }
    return self;
}

//- (instancetype)initWithJSONRPCClient:(NBMJSONRPCClient *)jsonRPCClient delegate:(id<NBMTreeClientDelegate>)delegate {
//    NSParameterAssert(jsonRPCClient);
//    
//    self = [super init];
//    if (self) {
//        _jsonRpcClient = jsonRPCClient;
//        _delegate = delegate;
//    }
//    return self;
//}

- (void)connect:(NSTimeInterval)timeout {
    if (!self.connected) {
        if (timeout <= 0) {
            timeout = kTreeClientTimeoutInterval;
        }
        [self setupJsonRpcClient:timeout];
    }
}

#pragma mark - Public

- (void)createTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    
}

#pragma mark - Private

- (void)setupJsonRpcClient:(NSTimeInterval)timeout {
    NBMJSONRPCClientConfiguration *jsonRpcClientConfig = [NBMJSONRPCClientConfiguration defaultConfiguration];
    jsonRpcClientConfig.requestTimeout = timeout;
    _jsonRpcClient = [[NBMJSONRPCClient alloc] initWithURL:_wsURL configuration:jsonRpcClientConfig delegate:self];
}

- (void)nbm_createTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    [self.jsonRpcClient sendRequestWithMethod:kCreateTreeMethod
                                   parameters:@{kTreeId: treeId}
                                   completion:^(NBMResponse *response) {
                                       
                                   }];
}

- (void)nbm_releaseTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    [self.jsonRpcClient sendRequestWithMethod:kReleaseTreeMethod
                                   parameters:@{kTreeId: treeId}
                                   completion:^(NBMResponse *response) {
                                       
                                   }];
};

- (void)nbm_setSource:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    [self.jsonRpcClient sendRequestWithMethod:kSetTreeSourceMethod
                                   parameters:@{kTreeId: treeId,
                                                kOfferSdp: sdpOffer}
                                   completion:^(NBMResponse *response) {
                                       
                                   }];
}

- (void)nbm_removeSourceOfTree:(NSString *)treeId completion:(void (^)(NSError *error))block {
    [self.jsonRpcClient sendRequestWithMethod:kRemoveTreeSourceMethod
                                   parameters:@{kTreeId: treeId}
                                   completion:^(NBMResponse *response) {
                                       
                                   }];
}



#pragma mark - NBMJSONRPCClientDelegate

- (void)clientDidConnect:(NBMJSONRPCClient *)client {
    self.connected = YES;
    if ([self.delegate respondsToSelector:@selector(client:isConnected:)]) {
        [self.delegate client:self isConnected:YES];
    }
}

- (void)client:(NBMJSONRPCClient *)client didReceiveRequest:(NBMRequest *)request {
    [self handleRequestEvent:request];
}

- (void)clientDidDisconnect:(NBMJSONRPCClient *)client {
    self.connected = NO;
    self.joined = NO;
    if ([self.delegate respondsToSelector:@selector(client:isConnected:)]) {
        [self.delegate client:self isConnected:NO];
    }
    //Autoretry
    //    if (!self.closeRequested) {
    //        if (!self.rpcError) {
    //            [self connect];
    //        }
    //    }
}

- (void)client:(NBMJSONRPCClient *)client didFailWithError:(NSError *)error {
    self.rpcError = error;
    if ([self.delegate respondsToSelector:@selector(client:didFailWithError:)]) {
        [self.delegate client:self didFailWithError:error];
    }
}

@end
