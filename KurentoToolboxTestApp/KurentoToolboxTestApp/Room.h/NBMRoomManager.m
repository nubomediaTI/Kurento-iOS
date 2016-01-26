//
//  NBMRoomManager.m
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

#import "NBMRoomManager.h"

static NSUInteger kConnectionManagerMaxIceAttempts = 3;

@interface NBMRoomManager () <NBMWebRTCPeerDelegate, NBMRoomClientDelegate>

@property (nonatomic, strong) NBMRoomClient *roomClient;
@property (nonatomic, strong) NBMWebRTCPeer *webRTCPeer;
@property (nonatomic, strong) NSMutableArray *mutableRemoteStreams;
@property (nonatomic, assign) NSUInteger retryCount;

@end

@implementation NBMRoomManager

#pragma mark - Init & Dealloc

- (instancetype)initWithDelegate:(id<NBMRoomManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _mutableRemoteStreams = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Public

- (void)connectToRoom:(NBMRoom *)room withConfiguration:(NBMMediaConfiguration *)configuration {
    NSParameterAssert(room);
    
    if (!self.roomClient) {
        [self setupRoomClient:room];
    }
    
    if (!self.webRTCPeer) {
        [self setupWebRTCSession];
    }
}

- (void)disconnect {
    //Add leave room message
    
    [self teardownRoomClient];
    [self teardownWebRTCSession];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.delegate roomManagerDidFinish:self];
    });
}

- (BOOL)isConnected {
    return self.roomClient.connected;
}

- (BOOL)isJoined {
    return self.roomClient.joined;
}

- (RTCMediaStream *)localStream
{
    return self.webRTCPeer.localStream;
}

- (NSSet *)remotePeers {
    return [self.roomClient.peers copy];
}

- (NSArray *)remoteStreams
{
    return [self.mutableRemoteStreams copy];
}

#pragma mark - Private

- (void)setupRoomClient:(NBMRoom *)room {
    self.roomClient = [[NBMRoomClient alloc] initWithRoom:room delegate:self];
    [_roomClient connect];
}

- (void)setupWebRTCSession {
    NBMMediaConfiguration *defaultConfig = [NBMMediaConfiguration defaultConfiguration];
    self.webRTCPeer = [[NBMWebRTCPeer alloc] initWithDelegate:self configuration:defaultConfig];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate roomManager:self didAddLocalStream:self.localStream];
    });
}

- (void)teardownRoomClient {
    self.roomClient = nil;
    self.retryCount = 0;
}

- (void)teardownWebRTCSession {
    [self.mutableRemoteStreams removeAllObjects];
    [self.webRTCPeer stopLocalMedia];
}

#pragma mark - NBMRoomDelegate

//Room Connection

- (void)client:(NBMRoomClient *)client isConnected:(BOOL)connected {
    if (connected) {
        self.retryCount = 0;
        [self.roomClient joinRoom];
    }
}

- (void)client:(NBMRoomClient *)client didFailWithError:(NSError *)error {
    [self.delegate roomManager:self didFailWithError:error];
}

//Room API

- (void)client:(NBMRoomClient *)client didJoinRoom:(NSError *)error {
    
}

- (void)client:(NBMRoomClient *)client didLeaveRoom:(NSError *)error {
    
}

//Room Events

- (void)client:(NBMRoomClient *)client partecipantJoined:(NBMPeer *)peer {
    
}

- (void)client:(NBMRoomClient *)client partecipantLeft:(NBMPeer *)peer {
    
}

- (void)client:(NBMRoomClient *)client partecipantEvicted:(NBMPeer *)peer {
    
}

- (void)client:(NBMRoomClient *)client partecipantPublished:(NBMPeer *)peer {
    
}

- (void)client:(NBMRoomClient *)client partecipantUnpublished:(NBMPeer *)peer {
    
}

- (void)client:(NBMRoomClient *)client didReceiveICECandidate:(RTCICECandidate *)candidate fromPartecipant:(NBMPeer *)peer {
    
}

- (void)client:(NBMRoomClient *)client didReceiveMessage:(NSString *)message fromPartecipant:(NBMPeer *)peer {
    
}

- (void)client:(NBMRoomClient *)client mediaErrorOccurred:(NSError *)error {
    
}

- (void)client:(NBMRoomClient *)client roomWasClosed:(NBMRoom *)room {
    
}

#pragma mark - NBMWebRTCPeerDelegate

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateAnswer:(RTCSessionDescription *)sdpAnswer forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateOffer:(RTCSessionDescription *)sdpOffer forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    [self.mutableRemoteStreams addObject:remoteStream];
    [self.delegate roomManager:self didAddStream:remoteStream];
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didRemoveStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    [self.mutableRemoteStreams removeObject:remoteStream];
    [self.delegate roomManager:self didRemoveStream:remoteStream];
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCICEConnectionState)state ofConnection:(NBMPeerConnection *)connection {
    
}

@end
