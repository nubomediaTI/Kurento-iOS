// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

#import "NBMTreeClient.h"
#import "NBMTreeClientDelegate.h"
#import "NBMTreeClientError.h"
#import "NBMTreeEndpoint.h"

#import "NBMJSONRPCClient.h"
#import "NBMJSONRPCClientDelegate.h"
#import "NBMLog.h"

#import "NBMRequest.h"
#import "NBMResponse.h"

#import <WebRTC/RTCIceCandidate.h>

static NSString* const kAddICECandidateMethod = @"addIceCandidate";
static NSString* const kICECandidateEvent = @"iceCandidate";
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

@property (nonatomic, copy, readwrite) NSString *treeId;
@property (nonatomic, readwrite) NSMutableSet *mutableTreeEndpoints;

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
        _treeId = NBMTreeModeNone;
        _mutableTreeEndpoints = [NSMutableSet set];
    }
    return self;
}

- (void)connect:(NSTimeInterval)timeout {
    if (self.connectionState == NBMTreeClientConnectionStateClosed) {
        if (timeout <= 0) {
            timeout = kTreeClientTimeoutInterval;
        }
        [self setupJsonRpcClient:timeout];
    }
}

- (void)connect {
    [self connect:-1];
}

- (void)dealloc {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    [self.jsonRpcClient cancelAllRequest];
}

#pragma mark - Public

- (void)createTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    return [self nbm_createTree:treeId completion:block];
}

- (NSString *)treeId {
    return _treeId;
}

- (NBMTreeClientConnectionState)connectionState {
    if (!self.jsonRpcClient) {
        return NBMTreeClientConnectionStateClosed;
    }
    return (NBMTreeClientConnectionState) self.jsonRpcClient.connectionState;
}
   
- (void)releaseTree:(NSString *)treeId completion:(void (^)(NSError *error))block {
    NSParameterAssert(treeId);
    return [self nbm_releaseTree:treeId completion:^(NSError *error) {
        _treeMode = NBMTreeModeNone;
        if (block) {
            block(error);
        }
    }];
}

- (void)setSource:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void (^)(NSString *sdpAnswer, NSError *))block {
    NSParameterAssert(sdpOffer);
    NSParameterAssert(treeId);
    return [self nbm_setSource:sdpOffer tree:treeId completion:^(NSString *sdpAnswer, NSError *error) {
        if (sdpAnswer) {
            _treeMode = NBMTreeModeMaster;
            if (block) {
                block(sdpAnswer, error);
            }
        }
    }];
}

- (void)removeSourceOfTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    NSParameterAssert(treeId);
    return [self nbm_removeSourceOfTree:treeId completion:^(NSError *error) {
        _treeMode = NBMTreeModeNone;
        if (block) {
            block(error);
        }
    }];
}

- (void)addSink:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void (^)(NBMTreeEndpoint *endpoint, NSError *))block {
    NSParameterAssert(sdpOffer);
    NSParameterAssert(treeId);
    return [self nbm_addSink:sdpOffer tree:treeId completion:^(NBMTreeEndpoint *endpoint, NSError *error) {
        if (endpoint) {
            _treeMode = NBMTreeModeViewer;
        }
        if (block) {
            block(endpoint, error);
        }
    }];
}

- (NSSet *)treeEndpoints {
    return [self.mutableTreeEndpoints copy];
}

- (void)removeSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void (^)(NSError *))block {
    NSParameterAssert(sinkId);
    NSParameterAssert(treeId);
    return [self nbm_removeSink:sinkId tree:treeId completion:^(NSError *error) {
        _treeMode = NBMTreeModeNone;
        if (block) {
            block(error);
        }
    }];
}

- (void)sendICECandidate:(RTCIceCandidate *)candidate forSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void (^)(NSError *))block {
    NSParameterAssert(candidate);
    NSParameterAssert(treeId);
    return [self nbm_sendICECandidate:candidate forSink:sinkId tree:treeId completion:block];
}

#pragma mark - Private

- (void)setupJsonRpcClient:(NSTimeInterval)timeout {
    NBMJSONRPCClientConfiguration *jsonRpcClientConfig = [NBMJSONRPCClientConfiguration defaultConfiguration];
    jsonRpcClientConfig.requestTimeout = timeout;
    _jsonRpcClient = [[NBMJSONRPCClient alloc] initWithURL:_wsURL configuration:jsonRpcClientConfig delegate:self];
}

- (void)nbm_createTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    NSDictionary *params;
    if (treeId.length > 0) {
        params = @{kTreeId: treeId};
    }
    [self.jsonRpcClient sendRequestWithMethod:kCreateTreeMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error;
//                                       NSString *value = [NBMTreeClient response:response getStringPropertyWithName:@"value" error:&error];
                                       if (!error) {
                                           self.treeId = treeId;
//                                           if (value) {
//                                               self.treeId = value;
//                                           }
                                       }
                                       if (block) {
                                           block(error);
                                       }
                                   }];
}

- (void)nbm_releaseTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    [self.jsonRpcClient sendRequestWithMethod:kReleaseTreeMethod
                                   parameters:@{kTreeId: treeId}
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMTreeClient errorFromResponse:response];
                                       if (!error) {
                                           self.treeId = nil;
                                       }
                                       if (block) {
                                           block(error);
                                       }
                                   }];
};

- (void)nbm_setSource:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    [self.jsonRpcClient sendRequestWithMethod:kSetTreeSourceMethod
                                   parameters:@{kTreeId: treeId,
                                                kOfferSdp: sdpOffer}
                                   completion:^(NBMResponse *response) {
                                       NSError *error;
                                       NSString *sdpAnswer = [NBMTreeClient response:response getStringPropertyWithName:kAnswerSdp error:&error];
                                       if (block) {
                                           block(sdpAnswer, error);
                                       }
                                   }];
}

- (void)nbm_removeSourceOfTree:(NSString *)treeId completion:(void (^)(NSError *error))block {
    [self.jsonRpcClient sendRequestWithMethod:kRemoveTreeSourceMethod
                                   parameters:@{kTreeId: treeId}
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMTreeClient errorFromResponse:response];
                                       if (block) {
                                           block(error);
                                       }
                                   }];
}

- (void)nbm_addSink:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void(^)(NBMTreeEndpoint *endpoint, NSError *error))block {
    [self.jsonRpcClient sendRequestWithMethod:kAddTreeSinkMethod
                                   parameters:@{kTreeId: treeId,
                                                kOfferSdp: sdpOffer}
                                   completion:^(NBMResponse *response) {
                                       NSError *error;
                                       NBMTreeEndpoint *treeEndpoint = [self treeEndpointFromResponse:response error:&error];
                                       if (treeEndpoint) {
                                           self.treeId = treeId;
                                           [self.mutableTreeEndpoints addObject:treeEndpoint];
                                       }
                                       if (block) {
                                           block(treeEndpoint, error);
                                       }
                                   }];
}

- (NBMTreeEndpoint *)treeEndpointFromResponse:(NBMResponse *)response error:(NSError **)error {
    NBMTreeEndpoint *treeEndpoint;
    id result = response.result;
    if (result) {
        NSString *sinkId = [NBMTreeClient response:response getStringPropertyWithName:kSinkId error:error];
        NSString *sdpAnswer = [NBMTreeClient response:response getStringPropertyWithName:kAnswerSdp error:error];
        if (!*error && sinkId.length > 0) {
            treeEndpoint = [[NBMTreeEndpoint alloc] initWithIdentifier:sinkId sdpAnswer:sdpAnswer];
        }
    } else {
        *error = [NBMTreeClient errorFromResponse:response];
    }
    
    return treeEndpoint;
}

- (NBMTreeEndpoint *)treeEndpointWithIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.identifier MATCHES %@", identifier];
    NSSet *filteredSet = [self.mutableTreeEndpoints filteredSetUsingPredicate:predicate];

    return [filteredSet anyObject];
}

- (void)nbm_removeSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void(^)(NSError *error))block {
    [self.jsonRpcClient sendRequestWithMethod:kRemoveTreeSinkMethod
                                   parameters:@{kTreeId: treeId,
                                                kSinkId: sinkId}
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMTreeClient errorFromResponse:response];
                                       NBMTreeEndpoint *treeEndpoint = [self treeEndpointWithIdentifier:treeId];
                                       if (!error && treeEndpoint) {
                                           [self.mutableTreeEndpoints removeObject:treeEndpoint];
                                       }
                                       if (block) {
                                           block(error);
                                       }
                                   }];
}

- (void)nbm_sendICECandidate:(RTCIceCandidate *)candidate forSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void(^)(NSError *error))block {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:treeId forKey:kTreeId];
    if (sinkId.length > 0) {
        [params setObject:sinkId forKey:kSinkId];
    }
    [params setObject:candidate.sdp forKey:kICECandidate];
    [params setObject:candidate.sdpMid forKey:kICESdpMid];
    [params setObject:@(candidate.sdpMLineIndex) forKey:kICESdpMLineIndex];
    [self.jsonRpcClient sendRequestWithMethod:kAddICECandidateMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMTreeClient errorFromResponse:response];
                                       if (block) {
                                           block(error);
                                       }
                                   }];
}

+ (NSString *)response:(NBMResponse *)response getStringPropertyWithName:(NSString *)name error:(NSError **)error {
    NSString *property;
    id result = response.result;
    if (result) {
        id value = [NBMTreeClient element:result getPropertyWithName:name ofClass:[NSString class] error:error];
        if (!*error) {
            property = value;
        }
    }
    else {
        *error = [NBMTreeClient errorFromResponse:response];
    }
    
    return property;
}

+ (id)element:(id)element getStringPropertyWithName:(NSString *)name error:(NSError **)error {
    return [self element:element getPropertyWithName:name ofClass:[NSString class] allowNil:NO error:error];
}

+ (id)element:(id)element getPropertyWithName:(NSString *)name ofClass:(Class)class error:(NSError **)error {
    return [self element:element getPropertyWithName:name ofClass:class allowNil:NO error:error];
}

+ (id)element:(id)element getPropertyWithName:(NSString *)name ofClass:(Class)class allowNil:(BOOL)allowNil error:(NSError **)error {
    if (element && ![element isKindOfClass:[NSDictionary class]]) {
        NSString *msg = [NSString stringWithFormat:@"Invalid response format. The response %@ should be a JSON object", element];
        *error = [NBMTreeClientError errorWithCode:NBMTreeClientTransportErrorCode message:msg];
        return nil;
    }
    
    id property = [(NSDictionary *)element objectForKey:name];
    if (!property) {
        if (!allowNil) {
            NSString *msg = [NSString stringWithFormat:@"Invalid method lacking parameter %@", name];
            *error = [NBMTreeClientError errorWithCode:NBMTreeClientTransportErrorCode message:msg];
            return nil;
        }
    }
    
    if (class == [NSString class]) {
        if ([property isKindOfClass:class]) {
            return property;
        }
    }
    
    if (class == [NSNumber class]) {
        if ([property isKindOfClass:class]) {
            return property;
        }
    }
    
    if (class == [NSArray class]) {
        if ([property isKindOfClass:class]) {
            return property;
        }
    }
    
    if (class == [NSDictionary class]) {
        if ([property isKindOfClass:class]) {
            return property;
        }
    }
    
    NSString *msg = [NSString stringWithFormat:@"Param %@ with value %@ is not an instance of %@ class", name, property, NSStringFromClass(class)];
    *error = [NBMTreeClientError errorWithCode:NBMTreeClientTransportErrorCode message:msg];
    
    return nil;
}

+ (NSError *)errorFromResponse:(NBMResponse *)response {
    NSError *error;
    //Timeout error
    if (!response) {
        NSString *msg = @"Tree API request goes timout";
        NSError *timeoutError = [NBMTreeClientError errorWithCode:NBMTreeClientTimeoutErrorCode message:msg];
        error = timeoutError;
    }
    else if (response.error) {
        //Response error -> error
        error = [response.error error];
    }
    return error;
}

#pragma mark Tree events

- (void)handleRequestEvent:(NBMRequest *)event {
    ((void (^)())
     @{kICECandidateEvent : ^{ [self iceCandidateReceived:event.parameters]; }}
     [event.method] ?:^{
           DDLogWarn(@"Unable to handle event with method: %@", event.method);
     })();
}

- (void)iceCandidateReceived:(id)params {
    NSError *error;
    //Candidate
    NSString *sdp = [NBMTreeClient element:params getStringPropertyWithName:kICECandidate error:&error];
    NSString *sdpMid = [NBMTreeClient element:params getStringPropertyWithName:kICESdpMid error:&error];
    NSNumber *index = [NBMTreeClient element:params getPropertyWithName:kICESdpMLineIndex ofClass:[NSNumber class] error:&error];
    RTCIceCandidate *candidate;
    if (!error) {
        candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:index.integerValue sdpMid:sdpMid];
    }
    
    NSString *treeId = [NBMTreeClient element:params getStringPropertyWithName:kTreeId error:&error];
    NSString *sinkId = [NBMTreeClient element:params getStringPropertyWithName:kSinkId error:&error];
    if (treeId.length > 0) {
        if ([self.delegate respondsToSelector:@selector(client:iceCandidateReceived:ofSink:tree:)]) {
            [self.delegate client:self iceCandidateReceived:candidate ofSink:sinkId tree:treeId];
        }
    }
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
