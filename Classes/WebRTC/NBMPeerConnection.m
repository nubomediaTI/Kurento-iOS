//
//  NBMPeerConnection.m
//  Kurento-iOS
//
//  Created by Marco Rossi on 12/10/15.
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMPeerConnection.h"
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCDataChannelConfiguration.h>
#import <NBMSessionDescriptionFactory.h>
#import "NBMLog.h"

@interface NBMPeerConnection ()

@property (nonatomic, strong) NSMutableArray *queuedRemoteCandidates;

@end

@implementation NBMPeerConnection

- (instancetype)initWithConnection:(RTCPeerConnection *)connection
{
    self = [super init];
    
    if (self) {
        _peerConnection = connection;
        _isInitiator = YES;
        _iceAttempts = 0;
    }
    
    return self;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return [self.peerConnection hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[NBMPeerConnection class]]) {
        NBMPeerConnection *otherConnection = (NBMPeerConnection *)object;
        return [otherConnection.peerConnection isEqual:self.peerConnection];
    }
    
    return NO;
}

- (void)dealloc {
    [self close];
}

#pragma mark - Public

- (void)addIceCandidate:(RTCIceCandidate *)candidate
{
    BOOL queueCandidates = self.peerConnection == nil || self.peerConnection.signalingState != RTCSignalingStateStable;
    
    if (queueCandidates) {
        if (!self.queuedRemoteCandidates) {
            self.queuedRemoteCandidates = [NSMutableArray array];
        }
        DDLogVerbose(@"Queued a remote ICE candidate for later.");
        [self.queuedRemoteCandidates addObject:candidate];
    } else {
        DDLogVerbose(@"Adding a remote ICE candidate.");
        [self.peerConnection addIceCandidate:candidate];
    }
}

- (void)drainRemoteCandidates
{
    DDLogVerbose(@"Drain %lu remote ICE candidates.", (unsigned long)[self.queuedRemoteCandidates count]);
    
    for (RTCIceCandidate *candidate in self.queuedRemoteCandidates) {
        [self.peerConnection addIceCandidate:candidate];
    }
    self.queuedRemoteCandidates = nil;
}

- (void)removeRemoteCandidates
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    
    [self.queuedRemoteCandidates removeAllObjects];
    self.queuedRemoteCandidates = nil;
}

- (void)close
{
    RTCMediaStream *localStream = [self.peerConnection.localStreams firstObject];
    if (localStream) {
        [self.peerConnection removeStream:localStream];
    }
    [self.peerConnection close];
    
    self.remoteStream = nil;
    self.peerConnection = nil;
}
@end
