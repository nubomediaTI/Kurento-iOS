//
//  NBMTreeManager.m
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

#import "NBMTreeManager.h"
#import "RTCPeerConnection.h"
#import "RTCSessionDescription.h"
#import "Reachability.h"

static NSUInteger kConnectionMaxIceAttempts = 3;
typedef void(^ErrorBlock)(NSError *error);
static NSString* const kConnectionId = @"connection";

@interface NBMTreeManager () <NBMWebRTCPeerDelegate, NBMTreeClientDelegate>

@property (nonatomic, strong) NBMTreeClient *treeClient;
@property (nonatomic, strong) NBMTreeEndpoint *localViewer;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NBMWebRTCPeer *webRTCPeer;
@property (nonatomic, strong) NSMutableArray *mutableRemoteStreams;
@property (nonatomic, strong) NSMutableArray *mutableCandidates;
@property (nonatomic, strong, readonly) NSString *localConnectionId;
@property (nonatomic, assign) NSUInteger retryCount;

@property (nonatomic, copy) ErrorBlock onConnectBlock;
@end

@implementation NBMTreeManager

- (instancetype)initWithTreeURL:(NSURL *)treeURL delegate:(id<NBMTreeManagerDelegate>)delegate; {
    self = [super init];
    if (self) {
        _treeClient = [[NBMTreeClient alloc] initWithURL:treeURL delegate:self];
        [_treeClient connect];
        [self setupWebRTCSession];
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    _onConnectBlock = nil;
}

#pragma mark - Public

//- (void)startMasteringTree:(NSString *)treeId completion:(void (^)(NSError *error))block {
//    NSParameterAssert(treeId);
//    BOOL hasMediaStarted = [self.webRTCPeer startLocalMedia];
//    if (hasMediaStarted) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            RTCMediaStream *localStream = self.webRTCPeer.localStream;
//            _mediaStream = localStream;
//            [self.delegate treeManager:self didAddStream:self.mediaStream];
//        });
//        [self.webRTCPeer generateOffer:kConnectionId completion:^(NSString *sdpOffer, NBMPeerConnection *connection) {
//            [self nbm_masterTree:treeId withOffer:sdpOffer completion:^(NSString *sdpAnswer, NSError *error) {
//                if (sdpAnswer) {
//                    [self.webRTCPeer processAnswer:sdpAnswer connectionId:connection.connectionId];
//                }
//                if (block) {
//                    block(error);
//                }
//            }];
//        }];
//    }
//}

- (void)startMasteringTree:(NSString *)treeId completion:(void (^)(NSError *error))block {
    _mutableCandidates = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [self.treeClient createTree:treeId completion:^(NSError *error) {
        BOOL hasMediaStarted = [weakSelf.webRTCPeer startLocalMedia];
        if (hasMediaStarted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                RTCMediaStream *localStream = weakSelf.webRTCPeer.localStream;
                _mediaStream = localStream;
                //[self.delegate treeManager:self didAddStream:self.mediaStream];
            });
            [weakSelf.webRTCPeer generateOffer:kConnectionId completion:^(NSString *sdpOffer, NBMPeerConnection *connection) {
                [weakSelf.treeClient setSource:sdpOffer tree:treeId completion:^(NSString *sdpAnswer, NSError *error) {
                    if (sdpAnswer) {
                        [weakSelf.webRTCPeer processAnswer:sdpAnswer connectionId:kConnectionId];
                        [weakSelf drainCandidates];
                    }
                    if (block) {
                        block(error);
                    }
                }];
            }];
        }
        else {
            //Error media not started?
            if (block) {
                block(nil);
            }
        }
    }];
}

- (void)stopMasteringTree:(NSString *)treeId completion:(void (^)(NSError *error))block {
    NSParameterAssert(treeId);
    [self.webRTCPeer stopLocalMedia];
    [self.delegate treeManager:self didRemoveStream:self.mediaStream];
    [self.webRTCPeer closeConnectionWithConnectionId:kConnectionId];
}

- (void)startViewingTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    NSParameterAssert(treeId);
    _mutableCandidates = [NSMutableArray array];
     __weak typeof(self) weakSelf = self;
    [self.webRTCPeer generateOffer:kConnectionId completion:^(NSString *sdpOffer, NBMPeerConnection *connection) {
        [weakSelf.treeClient addSink:sdpOffer tree:treeId completion:^(NBMTreeEndpoint *endpoint, NSError *error) {
            if (endpoint) {
                weakSelf.localViewer = endpoint;
                [weakSelf.webRTCPeer processAnswer:endpoint.sdpAnswer connectionId:kConnectionId];
                [weakSelf drainCandidates];
            }
            if (block) {
                block(error);
            }
        }];
    }];
}

- (void)stopViewingTree:(NSString *)treeId completion:(void (^)(NSError *))block {
    
}

- (NSString *)treeId {
    return self.treeClient.treeId;
}

- (void)selectCameraPosition:(NBMCameraPosition)cameraPosition {
    [self.webRTCPeer selectCameraPosition:cameraPosition];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate treeManager:self didAddStream:self.mediaStream];
    });
}

- (BOOL)isVideoEnabled {
    return [self.webRTCPeer isVideoEnabled];
}

- (void)enableVideo:(BOOL)enable {
    [self.webRTCPeer enableVideo:enable];
}

- (BOOL)isAudioEnabled {
    return [self.webRTCPeer isAudioEnabled];
}

- (void)enableAudio:(BOOL)enable {
    [self.webRTCPeer enableAudio:enable];
}

- (BOOL)isConnected {
    return self.treeClient.connected;
}

+ (NSSet *)keyPathsForValuesAffectingConnected {
    return [NSSet setWithObjects:@"self.treeClient.connected", nil];
}

#pragma mark - Private

- (void)setupTreeClient {
    self.treeClient = [[NBMTreeClient alloc] initWithURL:_treeURL delegate:self];
    [self.treeClient connect:-1];
}

- (void)setupWebRTCSession {
    NBMMediaConfiguration *defaultConfig = [NBMMediaConfiguration defaultConfiguration];
    NBMWebRTCPeer *webRTCManager = [[NBMWebRTCPeer alloc] initWithDelegate:self configuration:defaultConfig];
    
    if (!webRTCManager) {
        NSError *retryError = [NSError errorWithDomain:@"it.nubomedia.NBMTreeManager"
                                                  code:0
                                              userInfo:@{NSLocalizedDescriptionKey: @"Impossible to setup local media stream, check AUDIO & VIDEO permission"}];
        [self.delegate treeManager:self didFailWithError:retryError];
        return;
    }
    
    self.webRTCPeer = webRTCManager;
}

- (void)setupReachability
{
    self.reachability = [Reachability reachabilityWithHostName:[self.treeClient.url absoluteString]];
    
    __weak typeof(self) weakSelf = self;
    
    self.reachability.reachableBlock = ^(Reachability *reach) {
        DDLogDebug(@"REACHABLE: connected %@", weakSelf.isConnected ? @"YES" : @"NO");
        if (weakSelf.treeClient.connectionState == NBMTreeClientConnectionStateClosed) {
            [weakSelf.treeClient connect];
        }
    };
    
    [self.reachability startNotifier];
}

//- (void)nbm_masterTree:(NSString *)treeId withOffer:(NSString *)sdpOffer completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
//    __weak typeof(self) weakSelf = self;
//    [self.treeClient createTree:treeId completion:^(NSError *error) {
//        if (!error) {
//            [weakSelf.treeClient setSource:sdpOffer tree:treeId completion:^(NSString *sdpAnswer, NSError *error) {
//                if (block) {
//                    block(sdpAnswer, error);
//                }
//            }];
//        } else {
//            if (block) {
//                block(nil, error);
//            }
//        }
//    }];
//}

- (void)nbm_viewTree:(NSString *)treeId withOffer:(NSString *)sdpOffer completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    __weak typeof(self) weakSelf = self;
    [self.treeClient addSink:sdpOffer tree:treeId completion:^(NBMTreeEndpoint *endpoint, NSError *error) {
        if (!error) {
            weakSelf.localViewer = endpoint;
        }
        if (block) {
            block(endpoint.sdpAnswer, error);
        }
    }];
}

- (void)drainCandidates {
    for (RTCICECandidate *candidate in self.mutableCandidates) {
        NSString *sinkId = self.localViewer.identifier;
        [self.treeClient sendICECandidate:candidate forSink:sinkId tree:[self treeId] completion:nil];
    }
    self.mutableCandidates = nil;
}

#pragma mark - NBMTreeClientDelegate

- (void)client:(NBMTreeClient *)client isConnected:(BOOL)connected {
    if (connected) {
        self.retryCount = 0;
    }
    else {
        [self manageTreeClientConnection];
    }
}

- (void)manageTreeClientConnection {
    BOOL isReachable = self.reachability.isReachable;
    BOOL retryAllowed = self.retryCount < kConnectionMaxIceAttempts;
    
    if (retryAllowed && isReachable) {
        self.retryCount++;
        [self.treeClient connect];
    }
    else if (!retryAllowed || !isReachable) {
        DDLogInfo(@"Impossible to establish connection");
        NSError *retryError = [NSError errorWithDomain:@"it.nubomedia.NBMTreeManager"
                                                  code:0
                                              userInfo:@{NSLocalizedDescriptionKey: @"Impossible to establish WebSocket connection to Tree Server, check internet connection"}];
        [self.delegate treeManager:self didFailWithError:retryError];
    }
}

- (void)client:(NBMTreeClient *)client didFailWithError:(NSError *)error {
    //deal with timeout connection
    [self.delegate treeManager:self didFailWithError:error];
}

- (void)client:(NBMTreeClient *)client iceCandidateReceived:(RTCICECandidate *)candidate ofSink:(NSString *)sinkId tree:(NSString *)treeId {
//    NSString *connectionId;
//    if (sinkId) {
//        connectionId = viewerConnectionId;
//    } else {
//        connectionId = masterConnectionId;
//    }
    [self.webRTCPeer addICECandidate:candidate connectionId:kConnectionId];
}

#pragma mark - NBMWebRTCPeer

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    _mediaStream = remoteStream;
    [self.delegate treeManager:self didAddStream:remoteStream];
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didRemoveStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    _mediaStream = nil;
    [self.delegate treeManager:self didRemoveStream:remoteStream];
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection {
    [self.mutableCandidates addObject:candidate];
}

- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCICEConnectionState)state ofConnection:(NBMPeerConnection *)connection {

}

@end
