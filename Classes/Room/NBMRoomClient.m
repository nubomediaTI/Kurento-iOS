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

#import "NBMRoomClient.h"
#import "NBMRoomClientDelegate.h"
#import "NBMRoomClientError.h"

#import "NBMRequest.h"
#import "NBMResponse.h"

#import "NBMJSONRPCClient.h"
#import "NBMJSONRPCClientDelegate.h"

#import "NBMRoom.h"
#import "NBMPeer.h"
#import "NBMRoomError.h"

#import "NBMLog.h"

#import <WebRTC/RTCIceCandidate.h>

//CLIENT REQUESTS

//Send Message
static NSString* const kSendMessageRoomMethod = @"sendMessage";
static NSString* const kSendMessageUserParam = @"userMessage";
static NSString* const kSendMessageRoomParam = @"roomMessage";
static NSString* const kSendMessageMessageParam = @"message";

//Leave Room
static NSString* const kLeaveRoomMethod = @"leaveRoom";

//Join Room
static NSString* const kJoinRoomMethod = @"joinRoom";
static NSString* const kJoinRoomUserParam = @"user";
static NSString* const kJoinRoomParam = @"room";
static NSString* const kJoinDataChannelsParam = @"dataChannels";
static NSString* const kJoinRoomPeerIdParam = @"id";
static NSString* const kJoinRoomPeerStreamsParam = @"streams";
static NSString* const kJoinRoomPeerStramIdParam = @"id";

//Publish Video
static NSString* const kPublishVideoMethod = @"publishVideo";
static NSString* const kPublishVideoSdpOfferParam = @"sdpOffer";
static NSString* const kPublishVideoDoLoopbackParam = @"doLoopback";
static NSString* const kPublishVideoSdpAnswerParam = @"sdpAnswer";

//Unpublish Video
static NSString* const kUnpublishVideoMethod = @"unpublishVideo";

//Receive Video
static NSString* const kReceiveVideoMethod = @"receiveVideoFrom";
static NSString* const kReceiveVideoSdpOfferParam = @"sdpOffer";
static NSString* const kReceiveVideoSenderParam = @"sender";
static NSString* const kReceiveVideoSdpAnswerParam = @"sdpAnswer";

//Unsubscribe Video
static NSString* const kUnsubscribeFromVideoMethod = @"unsubscribeFromVideo";
static NSString* const kUnsubscribeFromVideoSenderParam = @"sender";

//On ICE Candidate
static NSString* const kOnIceCandidateMethod = @"onIceCandidate";
static NSString* const kOnIceCandidateEpnameParam = @"endpointName";
static NSString* const kOnIceCandidateCandidateParam = @"candidate";
static NSString* const kOnIceCandidateSdpMidParam = @"sdpMid";
static NSString* const kOnIceCandidateSdpMLineIndexParam = @"sdpMLineIndex";

//Custom Request
static NSString* const kCustomRequestMethod = @"customRequest";

//SERVER RESPONSES & EVENTS

//Partecipant Joined
static NSString* const kParticipantJoinedMethod = @"participantJoined";
static NSString* const kParticipantJoinedUserParam= @"id";

//Partecipant Left
static NSString* const kParticipantLeftMethod = @"participantLeft";
static NSString* const kParticipantLeftNameParam = @"name";

//Partecipant Evicted
static NSString* const kParticipantEvictedMethod = @"participantEvicted";

//Partecipant Published
static NSString* const kParticipantPublishedMethod = @"participantPublished";
static NSString* const kParticipantPublishedUserParam = @"id";
static NSString* const kParticipantPublishedStreamsParam = @"streams";
static NSString* const kParticipantPublishedStreamIdParam = @"id";

//Partecipant Unpublished
static NSString* const kParticipantUnpublishedMethod = @"participantUnpublished";
static NSString* const kParticipantUnpublishedUserParam = @"name";

//Partecipant Send Message
static NSString* const kParticipantSendMessageMethod = @"sendMessage";
static NSString* const kParticipantSendMessageUserParam = @"user";
static NSString* const kParticipantSendMessageRoomParam = @"room";
static NSString* const kParticipantSendMessageMessageParam = @"message";

//Room Closed
static NSString* const kRoomClosedMethod = @"roomClosed";
static NSString* const kRoomClosedParam = @"room";

//Media Error
static NSString* const kMediaErrorMethod = @"mediaError";
static NSString* const kMediaErrorErrorParam = @"error";

//ICE Candidate
static NSString* const kIceCandidateMethod = @"iceCandidate";
static NSString* const kIceCandidateEpnameParam = @"endpointName";
static NSString* const kIceCandidateCandidateParam = @"candidate";
static NSString* const kIceCandidateSdpMidParam = @"sdpMid";
static NSString* const kIceCandidateSdpMLineIndex = @"sdpMLineIndex";

typedef void(^JoinRoomBlock)(NSSet *peers, NSError *error);
typedef void(^ErrorBlock)(NSError *error);

@interface NBMRoomClient () <NBMJSONRPCClientDelegate>

@property (nonatomic, strong) NBMJSONRPCClient *jsonRpcClient;
@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL closeRequested;
@property (nonatomic, strong) NSError *rpcError;

@property (nonatomic, strong, readwrite) NBMRoom *room;
@property (nonatomic, strong) NSMutableDictionary *mutableRoomPeers;
@property (nonatomic, assign) BOOL joined;


@end

static NSTimeInterval kRoomClientTimeoutInterval = 5;

@implementation NBMRoomClient

#pragma mark - Public

- (instancetype)initWithRoom:(NBMRoom *)room delegate:(id<NBMRoomClientDelegate>)delegate {
    return [self initWithRoom:room timeout:-1 delegate:delegate];
}

- (instancetype)initWithRoom:(NBMRoom *)room timeout:(NSTimeInterval)timeout delegate:(id<NBMRoomClientDelegate>)delegate {
    NSParameterAssert(room);
    self = [super init];
    if (self) {
        _room = room;
        _delegate = delegate;
        
        if (timeout <= 0) {
            timeout = kRoomClientTimeoutInterval;
        }
        _timeout = timeout;
        [self setupRpcClient:_timeout];
    }
    return self;
}

- (void)connect {
    if (self.connectionState == NBMRoomClientConnectionStateClosed) {
        [self.jsonRpcClient connect];
    }
}

- (void)disconnect {
    [self.jsonRpcClient cancelAllRequest];
}

- (void)dealloc {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    [self disconnect];
}

#pragma mark - Properties

- (NBMRoom *)room {
    return _room;
}

- (NBMRoomClientConnectionState)connectionState {
    if (!self.jsonRpcClient) {
        return NBMRoomClientConnectionStateClosed;
    }
    return (NBMRoomClientConnectionState)self.jsonRpcClient.connectionState;
}

#pragma mark Join room

- (void)joinRoom:(JoinRoomBlock)completionBlock dataChannels:(BOOL)dataChannels {
    return [self nbm_joinRoom:self.room.name username:self.room.localPeer.identifier dataChannels:dataChannels completion:completionBlock];
}

- (void)joinRoom:(JoinRoomBlock)completionBlock {
    [self joinRoom:completionBlock dataChannels:NO];
}

- (void)joinRoomWithDataChannels:(BOOL)dataChannels {
    return [self joinRoom:^(NSSet *peers, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didJoinRoom:)]) {
            [self.delegate client:self didJoinRoom:error];
        }
    } dataChannels:dataChannels];
}

- (void)joinRoom {
    [self joinRoomWithDataChannels:NO];
}

#pragma mark Leave room

- (void)leaveRoom {
    return [self leaveRoom:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didLeaveRoom:)]) {
            [self.delegate client:self didLeaveRoom:error];
        }
    }];
}

- (void)leaveRoom:(ErrorBlock)block {
    return [self nbm_leaveRoom:block];
}

#pragma mark Publish video

- (void)publishVideo:(NSString *)sdpOffer loopback:(BOOL)doLoopback {
    return [self publishVideo:sdpOffer loopback:doLoopback completion:^(NSString *sdpAnswer, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didPublishVideo:loopback:error:)]) {
            [self.delegate client:self didPublishVideo:sdpOffer loopback:doLoopback error:error];
        }
    }];
}

- (void)publishVideo:(NSString *)sdpOffer loopback:(BOOL)doLoopback completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    [self nbm_publishVideo:sdpOffer loopback:doLoopback completion:block];
}

#pragma mark Unpublish video

- (void)unpublishVideo {
    return [self unpublishVideo:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didUnPublishVideo:)]) {
            [self.delegate client:self didUnPublishVideo:error];
        }
    }];
}

- (void)unpublishVideo:(void (^)(NSError *))block {
    [self nbm_unpublishVideo:block];
}

#pragma mark Receive video

- (void)receiveVideoFromPeer:(NBMPeer *)peer offer:(NSString *)sdpOffer {
    return [self receiveVideoFromPeer:peer offer:sdpOffer completion:^(NSString *sdpAnswer, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didReceiveVideoFrom:sdpAnswer:error:)]) {
            NBMPeer *updatedPeer = [self peerWithIdentifier:peer.identifier];
            [self.delegate client:self didReceiveVideoFrom:updatedPeer sdpAnswer:sdpAnswer error:error];
        }
    }];
}

- (void)receiveVideoFromPeer:(NBMPeer *)peer offer:(NSString *)sdpOffer completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    [self nbm_receiveVideoFromPeer:peer offer:sdpOffer completion:block];
}

#pragma mark Unsubscribe video

- (void)unsubscribeVideoFromPeer:(NBMPeer *)peer {
    return [self unsubscribeVideoFromPeer:peer completion:^(NSString *sdpAnswer, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didUnsubscribeVideoFrom:sdpAnswer:error:)]) {
            NBMPeer *updatedPeer = [self peerWithIdentifier:peer.identifier];
            [self.delegate client:self didUnsubscribeVideoFrom:updatedPeer sdpAnswer:sdpAnswer error:error];
        }
    }];
}

- (void)unsubscribeVideoFromPeer:(NBMPeer *)peer completion:(void (^)(NSString *, NSError *))block {
    [self nbm_unsubscribeVideoFormPeer:peer completion:block];
}

#pragma mark Send ICE candidate

- (void)sendICECandidate:(RTCIceCandidate *)candidate forPeer:(NBMPeer *)peer {
    return [self sendICECandidate:candidate forPeer:peer completion:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didSentICECandidate:forPeer:)]) {
            [self.delegate client:self didSentICECandidate:error forPeer:peer];
        }
    }];
}

- (void)sendICECandidate:(RTCIceCandidate *)candidate forPeer:(NBMPeer *)peer completion:(void (^)(NSError *))block {
    [self nbm_sendICECandidate:candidate forPeer:peer completion:block];
}

#pragma mark Send message

- (void)sendMessage:(NSString *)message {
    return [self sendMessage:message completion:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didSentMessage:)]) {
            [self.delegate client:self didSentMessage:error];
        }
    }];
}

- (void)sendMessage:(NSString *)message completion:(void (^)(NSError *))block {
    [self nbm_sendMessage:message completion:block];
}

#pragma mark Send custom request

- (void)sendCustomRequest:(NSDictionary *)params {
    return [self sendCustomRequest:params completion:^(NSError *error) {
        if ([self.delegate respondsToSelector:@selector(client:didSentCustomRequest:)]) {
            [self.delegate client:self didSentCustomRequest:error];
        }
    }];
}

- (void)sendCustomRequest:(NSDictionary *)params completion:(void (^)(NSError *))block {
    [self nbm_sendCustomRequest:params completion:block];
}

#pragma mark - Private

- (void)setupRpcClient:(NSTimeInterval)timeout {
    if (_room && !_jsonRpcClient) {
        NBMJSONRPCClientConfiguration *jsonRpcClientConfig = [NBMJSONRPCClientConfiguration defaultConfiguration];
        jsonRpcClientConfig.requestTimeout = timeout;
        _jsonRpcClient = [[NBMJSONRPCClient alloc] initWithURL:_room.url configuration:jsonRpcClientConfig delegate:self];
    }
}

#pragma mark Join room

- (void)nbm_joinRoom:(NSString *)roomName username:(NSString *)username dataChannels:(BOOL)dataChannels completion:(JoinRoomBlock)block {
    [self.jsonRpcClient sendRequestWithMethod:kJoinRoomMethod
                                   parameters:@{kJoinRoomParam: roomName ?: @"",
                                                kJoinRoomUserParam: username ?: @"",
                                                kJoinDataChannelsParam: dataChannels ? @YES : @NO}
                                   completion:^(NBMResponse *response) {
                                       NSError *error;
                                       NSSet *peers = [self peersFromResponse:response error:&error];
                                       
                                       if (!error) {
                                           self.joined = YES;
                                       }
                                       
                                       if (block) {
                                           block (peers, error);
                                       }
                                   }];
}


- (NSSet *)peersFromResponse:(NBMResponse *)response error:(NSError **)error {
    NSMutableDictionary *peers;
    id result = response.result;
    if (result) {
        id value = [NBMRoomClient element:result getPropertyWithName:@"value" ofClass:[NSArray class] error:error];
        if (!*error) {
            peers = [NSMutableDictionary dictionary];
            NSArray *jsonPeers = (NSArray *)value;
            if ([jsonPeers count] > 0) {
                for (NSDictionary* jsonPeer in jsonPeers) {
                    if (*error) {
                        return nil;
                        break;
                    }
                    NSString *peerId = [NBMRoomClient element:jsonPeer getPropertyWithName:kJoinRoomPeerIdParam ofClass:[NSString class] error:error];
                    if (peerId) {
                        NBMPeer *peer = [[NBMPeer alloc] initWithId:peerId];
                        NSArray *jsonStreams = [NBMRoomClient element:jsonPeer getPropertyWithName:kJoinRoomPeerStreamsParam ofClass:[NSArray class] error:error];
                        for (NSDictionary *jsonStream in jsonStreams) {
                            NSString *streamId = [NBMRoomClient element:jsonStream getPropertyWithName:kJoinRoomPeerStramIdParam ofClass:[NSString class] error:error];
                            [peer addStream:streamId];
                        }
                        [peers setObject:peer forKey:peerId];
                    }
                }
            }
            self.mutableRoomPeers = peers;
        }
    }
    else {
        *error = [NBMRoomClient errorFromResponse:response];
    }
    
    NSSet *peersSet = [NSSet setWithArray:[peers allValues]];
    
    return peersSet;
}

#pragma mark Leave room

- (void)nbm_leaveRoom:(ErrorBlock)block {
    [self.jsonRpcClient sendRequestWithMethod:kLeaveRoomMethod
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMRoomClient errorFromResponse:response];
                                       if (!error) {
                                           self.joined = NO;
                                       }
                                       if (block) {
                                           block(error);
                                       }
                                   }];
}

// Publish video

- (void)nbm_publishVideo:(NSString *)sdpOffer loopback:(BOOL)doLoopback completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    NSDictionary *params = @{kPublishVideoSdpOfferParam: sdpOffer ?: @"",
                             kPublishVideoDoLoopbackParam: @(doLoopback)};
    
    [self.jsonRpcClient sendRequestWithMethod:kPublishVideoMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error;
                                       NSString *sdpAnswer = [self sdpAnswerFromResponse:response error:&error];
                                       
                                       if (!error) {
                                           NBMPeer *localPeer = self.room.localPeer;
                                           [localPeer addStream:[self mainStreamOfPeer:localPeer]];
                                       }
                                       
                                       if (block) {
                                           block(sdpAnswer, error);
                                       }
                                      
                                   }];
}

- (NSString *)sdpAnswerFromResponse:(NBMResponse *)response error:(NSError **)error {
    NSString *sdpAnswer;
    id result = response.result;
    if (result) {
        id value = [NBMRoomClient element:result getPropertyWithName:kPublishVideoSdpAnswerParam ofClass:[NSString class] error:error];
        if (!*error) {
            sdpAnswer = value;
        }
    }
    else {
        *error = [NBMRoomClient errorFromResponse:response];
    }

    return sdpAnswer;
}

#pragma mark Unpublish video

- (void)nbm_unpublishVideo:(void (^)(NSError *error))block {
    [self.jsonRpcClient sendRequestWithMethod:kUnpublishVideoMethod
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMRoomClient errorFromResponse:response];
                                       if (!error) {
                                           NBMPeer *localPeer = self.room.localPeer;
                                           [localPeer removeStream:[self mainStreamOfPeer:localPeer]];
                                       }
                                       if (block) {
                                           block(error);
                                       }
    }];
}

#pragma mark Receive video

- (void)nbm_receiveVideoFromPeer:(NBMPeer *)peer offer:(NSString *)sdpOffer completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    
    NSString *sender = [self senderFromPeer:peer];
    
    NSDictionary *params = @{kReceiveVideoSenderParam: sender,
                             kReceiveVideoSdpOfferParam: sdpOffer ?: @""};
    [self.jsonRpcClient sendRequestWithMethod:kReceiveVideoMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error;
                                       NSString *sdpAnswer = [self sdpAnswerFromResponse:response error:&error];
                                       if (!error) {
                                           //Add peer with (updated?) stream
//                                           if (peer) {
//                                               [peer addStream:[self mainStreamOfPeer:peer]];
//                                               [self.mutableRoomPeers setObject:peer forKey:peer.identifier];
//                                           }
                                       }
                                       if (block) {
                                           block(sdpAnswer, error);
                                       }
    }];
}

#pragma mark Unsubscribe video

- (void)nbm_unsubscribeVideoFormPeer:(NBMPeer *)peer completion:(void (^)(NSString *sdpAnswer, NSError *error))block {
    NSString *sender = [self senderFromPeer:peer];
    NSDictionary *params = @{kUnsubscribeFromVideoSenderParam: sender};
    
    [self.jsonRpcClient sendRequestWithMethod:kUnsubscribeFromVideoMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error;
                                       NSString *sdpAnswer = [self sdpAnswerFromResponse:response error:&error];
                                       if (!error) {
                                           //Add peer with (removed?) stream
//                                           if (peer) {
//                                               [peer removeStream:[self mainStreamOfPeer:peer]];
//                                               [self.mutableRoomPeers setObject:peer forKey:peer.identifier];
//                                           }
                                       }
                                       if (block) {
                                           block(sdpAnswer, error);
                                       }
    }];
}

#pragma mark Send ICE candidate

- (void)nbm_sendICECandidate:(RTCIceCandidate *)candidate forPeer:(NBMPeer *)peer completion:(void (^)(NSError *error))block {
    NSDictionary *params = @{kOnIceCandidateEpnameParam: peer.identifier,
                             kOnIceCandidateCandidateParam: candidate.sdp ?: @"",
                             kOnIceCandidateSdpMidParam: candidate.sdpMid ?: @"",
                             kOnIceCandidateSdpMLineIndexParam: @(candidate.sdpMLineIndex)};
    
    [self.jsonRpcClient sendRequestWithMethod:kOnIceCandidateMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMRoomClient errorFromResponse:response];
                                       if (block) {
                                           block(error);
                                       }
    }];
}

#pragma mark Send message

- (void)nbm_sendMessage:(NSString *)message completion:(void (^)(NSError *error))block {
    NSDictionary *params = @{kSendMessageRoomParam: self.room.name,
                             kSendMessageUserParam: self.room.localPeer.identifier,
                             kSendMessageMessageParam: message ?: @""};
    [self.jsonRpcClient sendRequestWithMethod:kSendMessageRoomMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMRoomClient errorFromResponse:response];
                                       if (block) {
                                           block(error);
                                       }
                                   }];
}

#pragma mark Send custom request

- (void)nbm_sendCustomRequest:(id)params completion:(void (^)(NSError *error))block {
    if (!params) {
        params = @{};
    }
    [self.jsonRpcClient sendRequestWithMethod:kCustomRequestMethod
                                   parameters:params
                                   completion:^(NBMResponse *response) {
                                       NSError *error = [NBMRoomClient errorFromResponse:response];
                                       if (block) {
                                           block(error);
                                       }
                                   }];
}

- (NBMPeer *)peerWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    NBMPeer *peer = [self.mutableRoomPeers objectForKey:identifier];
    if (!peer) {
        peer = self.room.localPeer;
    }
    
    return peer;
}

- (NSArray *)peers {
    NSArray *allPeers = [self.mutableRoomPeers allValues];
 
    return [allPeers copy];
}

#pragma mark Room events

- (void)handleRequestEvent:(NBMRequest *)event {
    ((void (^)())
     @{kParticipantJoinedMethod : ^{
        [self partecipantJoined:event.parameters];
    },
       kParticipantLeftMethod : ^ {
        [self partecipantLeft:event.parameters];
    },
       kParticipantPublishedMethod : ^{
        [self partecipantPublished:event.parameters];
    },
       kParticipantUnpublishedMethod : ^{
        [self partecipantUnpublished:event.parameters];
    },
       kIceCandidateMethod : ^{
        [self iceCandidateReceived:event.parameters];
    },
       kMediaErrorMethod : ^{
        [self mediaErrorReceived:event.parameters];
    },
       kParticipantEvictedMethod : ^{
        [self partecipantEvicted];
    },
       kParticipantSendMessageMethod : ^{
        [self messageReceived:event.parameters];
    },
       kRoomClosedMethod : ^{
        [self roomWasClosed];
    }
       }[event.method] ?:^{
           DDLogWarn(@"Unable to handle event with method: %@", event.method);
    })();
}

- (void)partecipantJoined:(id)params {
    NSError *error;
    NSString *peerId = [NBMRoomClient element:params getStringPropertyWithName:kParticipantJoinedUserParam error:&error];
    //NBMPeer *peer = [self peerWithIdentifier:peerId];
    NBMPeer *peer = [[NBMPeer alloc] initWithId:peerId];
    [self.mutableRoomPeers setObject:peer forKey:peerId];
    if ([self.delegate respondsToSelector:@selector(client:participantJoined:)]) {
        [self.delegate client:self participantJoined:peer];
    }
}

- (void)partecipantLeft:(id)params {
    NSError *error;
    NSString *peerId = [NBMRoomClient element:params getStringPropertyWithName:kParticipantLeftNameParam error:&error];
    NBMPeer *peer = [self peerWithIdentifier:peerId];
    [self.mutableRoomPeers removeObjectForKey:peerId];
    if ([self.delegate respondsToSelector:@selector(client:participantLeft:)]) {
        [self.delegate client:self participantLeft:peer];
    }
}

- (void)partecipantPublished:(id)params {
    NSError *error;
    NSString *peerId = [NBMRoomClient element:params getStringPropertyWithName:kParticipantPublishedUserParam error:&error];
    NBMPeer *peer;
    if (peerId) {
        peer = [self peerWithIdentifier:peerId];
        NSArray *jsonStreams = [NBMRoomClient element:params getPropertyWithName:kParticipantPublishedStreamsParam ofClass:[NSArray class] error:&error];
        for (NSDictionary *jsonStream in jsonStreams) {
            NSString *streamId = [NBMRoomClient element:jsonStream getStringPropertyWithName:kParticipantPublishedStreamIdParam error:&error];
            [peer addStream:streamId];
        }
    }
    if ([self.delegate respondsToSelector:@selector(client:participantPublished:)]) {
        [self.delegate client:self participantPublished:peer];
    }
}

- (void)partecipantUnpublished:(id)params {
    NSError *error;
    NSString *peerId = [NBMRoomClient element:params getStringPropertyWithName:kParticipantUnpublishedUserParam error:&error];
    NBMPeer *peer = [self peerWithIdentifier:peerId];
    if (peer) {
        [peer removeStream:@"webcam"];
    }
    if ([self.delegate respondsToSelector:@selector(client:participantUnpublished:)]) {
        [self.delegate client:self participantUnpublished:peer];
    }
}

- (void)iceCandidateReceived:(id)params {
    NSError *error;
    NSString *peerId = [NBMRoomClient element:params getStringPropertyWithName:kIceCandidateEpnameParam error:&error];
    NBMPeer *peer = [self peerWithIdentifier:peerId];
    NSString *sdpMid = [NBMRoomClient element:params getStringPropertyWithName:kIceCandidateSdpMidParam error:&error];
    NSString *sdp = [NBMRoomClient element:params getStringPropertyWithName:kIceCandidateCandidateParam error:&error];
    NSNumber *sdpMLineIndexNumber = [NBMRoomClient element:params getPropertyWithName:kIceCandidateSdpMLineIndex ofClass:[NSNumber class] error:&error];
    RTCIceCandidate *candidate;
    if (sdpMid && sdp && sdpMLineIndexNumber) {
        candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:[sdpMLineIndexNumber intValue] sdpMid:sdpMid];
    }
    if ([self.delegate respondsToSelector:@selector(client:didReceiveICECandidate:fromParticipant:)]) {
        [self.delegate client:self didReceiveICECandidate:candidate fromParticipant:peer];
    }
}

- (void)partecipantEvicted {
    if ([self.delegate respondsToSelector:@selector(client:participantEvicted:)]) {
        [self.delegate client:self participantEvicted:self.room.localPeer];
    }
}

- (void)roomWasClosed {
    if ([self.delegate respondsToSelector:@selector(client:roomWasClosed:)]) {
        [self.delegate client:self roomWasClosed:self.room];
    }
}

- (void)messageReceived:(id)params {
    NSError *error;
    //NSString *roomName = [NBMRoomClient element:params getStringPropertyWithName:kPartecipantSendMessageRoomParam error:&error];
    NSString *senderId = [NBMRoomClient element:params getStringPropertyWithName:kParticipantSendMessageUserParam error:&error];
    NBMPeer *peer = [self peerWithIdentifier:senderId];
    NSString *msg = [NBMRoomClient element:params getStringPropertyWithName:kParticipantSendMessageMessageParam error:&error];
    if ([self.delegate respondsToSelector:@selector(client:didReceiveMessage:fromParticipant:)]) {
        [self.delegate client:self didReceiveMessage:msg fromParticipant:peer];
    }
}

- (void)mediaErrorReceived:(id)params {
    NSError *error;
    NSString *errorMsg = [NBMRoomClient element:params getStringPropertyWithName:kMediaErrorErrorParam error:&error];
    NSError *mediaError = [NBMRoomError errorWithCode:NBMRoomGenericErrorRoomErrorCode message:errorMsg];
    if ([self.delegate respondsToSelector:@selector(client:mediaErrorOccurred:)]) {
        [self.delegate client:self mediaErrorOccurred:mediaError];
    }
}

#pragma mark - Utility

- (NSString *)senderFromPeer:(NBMPeer *)peer {
    NSMutableString *sender = [NSMutableString string];
    NSString *peerId = peer.identifier;
    NSString *streamId = [self mainStreamOfPeer:peer];
    if (peerId) {
        [sender appendString:peerId];
    }
    [sender appendString:@"_"];
    [sender appendString:streamId];
    
    return sender;
}

- (NSString *)mainStreamOfPeer:(NBMPeer *)peer {
    NSString *streamId = @"webcam";
    return streamId;
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
        *error = [NBMRoomError errorWithCode:NBMTransportResponseErrorRoomErrorCode message:msg];
        return nil;
    }
    
    id property = [(NSDictionary *)element objectForKey:name];
    if (!property) {
        if (!allowNil) {
            NSString *msg = [NSString stringWithFormat:@"Invalid method lacking parameter %@", name];
            *error = [NBMRoomError errorWithCode:NBMTransportErrorRoomErrorCode message:msg];
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
    *error = [NBMRoomError errorWithCode:NBMTransportErrorRoomErrorCode message:msg];
    
    return nil;
}

+ (NSError *)errorFromResponse:(NBMResponse *)response {
    NSError *error;
    //Timeout error
    if (!response) {
        NSString *msg = @"Room API request goes timout";
        NSError *timeoutError = [NBMRoomClientError errorWithCode:NBMRoomClientTimeoutErrorCode message:msg];
        error = timeoutError;
    }
    else if (response.error) {
        //Response error -> error
        error = [response.error error];
    }
    return error;
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
