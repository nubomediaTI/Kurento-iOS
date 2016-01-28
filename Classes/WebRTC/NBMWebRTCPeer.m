//
//  NBMWebRTCPeer.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMWebRTCPeer.h"
#import "NBMLog.h"

#import "NBMSessionDescriptionFactory.h"
#import "NBMMediaConfiguration.h"
#import "NBMPeerConnection.h"

#import <AVFoundation/AVFoundation.h>

//Web-RTC classes
#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoTrack.h"
#import "RTCAudioTrack.h"

@interface NBMWebRTCPeer () <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate, RTCMediaStreamTrackDelegate>

@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) NSMutableArray *iceServers;
@property (nonatomic, strong) NSMutableDictionary *connectionMap;

@property (nonatomic, assign) NBMCameraPosition cameraPosition;
@property (nonatomic, strong) RTCMediaStream *localStream;

@property(nonatomic, assign) BOOL isInitiator;

@end

@implementation NBMWebRTCPeer

#pragma mark - Public

- (instancetype)initWithDelegate:(id<NBMWebRTCPeerDelegate>)delegate configuration:(NBMMediaConfiguration *)configuration
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _mediaConfiguration = configuration;
        [RTCPeerConnectionFactory initializeSSL];
        _peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
        _connectionMap = [NSMutableDictionary dictionary];
        
        [self setupLocalMedia];
    }
    
    return self;
}

- (void)processOffer:(NSString *)sdpOffer connectionId:(NSString *)connectionId {
    NSParameterAssert(sdpOffer);
    NSParameterAssert(connectionId);
    
    NBMPeerConnection *connection = self.connectionMap[connectionId];
    //    if (connection) {
    //        DDLogWarn(@"Connection already exixts - id: %@", connectionId);
    //        return;
    //    }
    if (!connection) {
        connection = [self connectionWrapperWithConnectionId:connectionId servers:nil];
    }
    connection.isInitiator = NO;
    RTCSessionDescription *description = [[RTCSessionDescription alloc] initWithType:@"offer" sdp:sdpOffer];
    [connection.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:description];
    
    self.connectionMap[connectionId] = connection;
    
    //TODO:Renegotiate active connections
}

- (void)generateOffer:(NSString *)connectionId {
    NSParameterAssert(connectionId);
   
    NBMPeerConnection *connection = self.connectionMap[connectionId];
//    if (connection) {
//        DDLogWarn(@"Connection already exixts - id: %@", connectionId);
//        return;
//    }
    if (!connection) {
        connection = [self connectionWrapperWithConnectionId:connectionId servers:nil];
    }
    connection.isInitiator = YES;
    RTCMediaConstraints *constraints = [NBMSessionDescriptionFactory offerConstraints];
    [connection.peerConnection createOfferWithDelegate:self constraints:constraints];

    self.connectionMap[connectionId] = connection;
    
    //TODO:Renegotiate active connections
}

- (void)processAnswer:(NSString *)sdpAnswer connectionId:(NSString *)connectionId {
    NBMPeerConnection *connection = self.connectionMap[connectionId];
    RTCSessionDescription *description = [[RTCSessionDescription alloc] initWithType:@"answer" sdp:sdpAnswer];
    [connection.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:description];
}

- (void)addICECandidate:(RTCICECandidate *)candidate connectionId:(NSString *)connectionId {
    //TODO: Handle case where ICE candidates reach us before we are able to fetch ICE servers and create a connection.
    NBMPeerConnection *connection = self.connectionMap[connectionId];
    [connection addIceCandidate:candidate];
}

- (NBMPeerConnection *)connectionWithConnectionId:(NSString *)connectionId {
    return self.connectionMap[connectionId];
}

- (void)closeConnectionWithConnectionId:(NSString *)connectionId {
    NSParameterAssert(connectionId);
    
    NBMPeerConnection *connection = self.connectionMap[connectionId];
    if (!connection) {
        DDLogWarn(@"No connection to close with id: %@", connectionId);
        return;
    }
    
    RTCMediaStream *remoteStream = connection.remoteStream;
    [connection close];
    if (remoteStream) {
        [self.delegate webRTCPeer:self didRemoveStream:remoteStream ofConnection:connection];
    }
    
    [self.connectionMap removeObjectForKey:connectionId];
}

- (void)stopLocalMedia
{
    NSArray *connections = [self.connectionMap allValues];
    for (NBMPeerConnection *connection in connections) {
        [connection close];
    }
    
    [self.localStream removeAudioTrack:[self.localStream.audioTracks firstObject]];
    [self.localStream removeVideoTrack:[self.localStream.videoTracks firstObject]];
    
    self.localStream = nil;
}

- (NSUInteger)connectionCount
{
    return [self.connectionMap count];
}

- (NSUInteger)activeConnectionCount
{
    return [[self activeConnections] count];
}

#pragma mark - Private

- (NSArray *)activeConnections
{
    NSSet *keys = [self.connectionMap keysOfEntriesPassingTest:^BOOL(NSString *peerId, NBMPeerConnection *connection, BOOL *stop) {
        RTCPeerConnection *rtcConnection = connection.peerConnection;
        if (rtcConnection.signalingState == RTCSignalingStable && rtcConnection.iceConnectionState != RTCICEConnectionFailed) {
            return YES;
        }
        return NO;
    }];
    
    return [self.connectionMap objectsForKeys:[keys allObjects] notFoundMarker:[NSNull null]];
}

- (NBMPeerConnection *)connectionWrapperWithConnectionId:(NSString *)connectionId servers:(NSArray *)iceServers {
    NSParameterAssert(connectionId);
    
    RTCPeerConnection *connection = nil;
//    if (iceServers) {
//        connection = [self peerConnectionWithServers:iceServers];
//    }
    connection = [self peerConnectionWithServers:iceServers];
    NBMPeerConnection *connectionWrapper = [[NBMPeerConnection alloc] initWithConnection:connection];
    connectionWrapper.connectionId = connectionId;
    
    return connectionWrapper;
}

- (RTCPeerConnection *)peerConnectionWithServers:(NSArray *)iceServers {
    RTCMediaConstraints *constraints = [NBMSessionDescriptionFactory connectionConstraints];
    RTCPeerConnection *connection = [self.peerConnectionFactory peerConnectionWithICEServers:iceServers constraints:constraints delegate:self];
    
    [connection addStream:self.localStream];
    
    return connection;
}

- (NBMPeerConnection *)wrapperForConnection:(RTCPeerConnection *)connection
{
    NBMPeerConnection *connectionWrapper = nil;
    NSArray *connectionWrappers = [self.connectionMap allValues];
    
    for (NBMPeerConnection *wrapper in connectionWrappers) {
        if ([wrapper.peerConnection isEqual:connection]) {
            connectionWrapper = wrapper;
            break;
        }
    }
    
    return connectionWrapper;
}

- (void)dealloc {
    
    [_connectionMap removeAllObjects];
    
    _localStream = nil;
    _peerConnectionFactory = nil;
    
    [RTCPeerConnectionFactory deinitializeSSL];
}

- (void)setupLocalMedia
{
    RTCMediaConstraints *videoConstraints = nil;
    
#if !TARGET_IPHONE_SIMULATOR
    
    
#endif
    
    [self setupLocalMediaWithVideoConstraints:videoConstraints];
}

- (void)setupLocalMediaWithVideoConstraints:(RTCMediaConstraints *)videoConstraints
{
    RTCMediaStream *localMediaStream = [_peerConnectionFactory mediaStreamWithLabel:@"ARDAMS"];
    RTCAudioTrack *audioTrack = [self.peerConnectionFactory audioTrackWithID:@"ARDAMSa0"];
    if (audioTrack) {
        [localMediaStream addAudioTrack:audioTrack];
    }
    
    // The iOS simulator doesn't provide any sort of camera capture
    // support or emulation (http://goo.gl/rHAnC1) so don't bother
    // trying to open a local video track.
    
#if !TARGET_IPHONE_SIMULATOR
    
    RTCVideoCapturer *videoCapturer = nil;
    
    NSString *cameraId = [self cameraDevice:_cameraPosition];
    
    NSAssert(cameraId, @"Unable to get the front camera id");
    
    videoCapturer = [RTCVideoCapturer capturerWithDeviceName:cameraId];
    
    RTCVideoSource *videoSource = [self.peerConnectionFactory videoSourceWithCapturer:videoCapturer constraints:videoConstraints];
    RTCVideoTrack *localVideoTrack = [self.peerConnectionFactory videoTrackWithID:@"ARDAMSv0" source:videoSource];
    
    if (localVideoTrack) {
        [localMediaStream addVideoTrack:localVideoTrack];
    }
#endif
    
    self.localStream = localMediaStream;
}

- (NSString *)cameraDevice:(NBMCameraPosition)cameraPosition
{
    NSString *cameraID = nil;
    
    for (AVCaptureDevice* captureDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (captureDevice.position == (AVCaptureDevicePosition)cameraPosition) {
            cameraID = [captureDevice localizedName];
            break;
        }
    }
    
    return cameraID;
}

- (NSString *)stringForSignalingState:(RTCSignalingState)state
{
    switch (state) {
        case RTCSignalingStable:
            return @"Stable";
            break;
        case RTCSignalingHaveLocalOffer:
            return @"Have Local Offer";
            break;
        case RTCSignalingHaveRemoteOffer:
            return @"Have Remote Offer";
            break;
        case RTCSignalingClosed:
            return @"Closed";
            break;
        default:
            return @"Other state";
            break;
    }
}

- (NSString *)stringForConnectionState:(RTCICEConnectionState)state
{
    switch (state) {
        case RTCICEConnectionNew:
            return @"New";
            break;
        case RTCICEConnectionChecking:
            return @"Checking";
            break;
        case RTCICEConnectionConnected:
            return @"Connected";
            break;
        case RTCICEConnectionCompleted:
            return @"Completed";
            break;
        case RTCICEConnectionFailed:
            return @"Failed";
            break;
        case RTCICEConnectionDisconnected:
            return @"Disconnected";
            break;
        case RTCICEConnectionClosed:
            return @"Closed";
            break;
        default:
            return @"Other state";
            break;
    }
}

- (NSString *)stringForGatheringState:(RTCICEGatheringState)state
{
    switch (state) {
        case RTCICEGatheringNew:
            return @"New";
            break;
        case RTCICEGatheringGathering:
            return @"Gathering";
            break;
        case RTCICEGatheringComplete:
            return @"Complete";
            break;
        default:
            return @"Other state";
            break;
    }
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection
 signalingStateChanged:(RTCSignalingState)stateChanged {
    DDLogVerbose(@"Peer connection: Signaling state changed: %@", [self stringForSignalingState:stateChanged]);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream {
    DDLogVerbose(@"Received %lu video tracks and %lu audio tracks of peer connection",
                 (unsigned long)stream.videoTracks.count, (unsigned long)stream.audioTracks.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
        connection.remoteStream = stream;
        RTCVideoTrack *videoTrack = [stream.videoTracks firstObject];
        videoTrack.delegate = self;
        
        [self.delegate webRTCPeer:self didAddStream:stream ofConnection:connection];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream {
    DDLogVerbose(@"Peer connection stream was removed");
    dispatch_async(dispatch_get_main_queue(), ^{
        NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
        connection.remoteStream = nil;
        
        [self.delegate webRTCPeer:self didRemoveStream:stream ofConnection:connection];
    });
}

- (void)peerConnectionOnRenegotiationNeeded:
(RTCPeerConnection *)peerConnection {
    DDLogVerbose(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState {
    DDLogVerbose(@"ICE state changed: %@", [self stringForConnectionState:newState]);
    dispatch_async(dispatch_get_main_queue(), ^{
        NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
        if (!connection) {
            return;
        }
        
        if (newState == RTCICEConnectionFailed) {
            connection.iceAttempts++;
            [connection removeRemoteCandidates];
        }
        else if (newState == RTCICEConnectionConnected) {
            connection.iceAttempts = 0;
        }
        
        [self.delegate webrtcPeer:self iceStatusChanged:newState ofConnection:connection];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState {
    DDLogVerbose(@"ICE gathering state changed: %@", [self stringForGatheringState:newState]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (newState == RTCICEGatheringGathering) {
            //Is this check needed?
            if (peerConnection.iceGatheringState == RTCICEGatheringGathering) {
                NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
                [connection drainRemoteCandidates];
            }
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
        if (!connection) {
            return;
        }
        
        [self.delegate webRTCPeer:self hasICECandidate:candidate forConnection:connection];
    });
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel {
    DDLogVerbose(@"Peer connection did open data channel: %@", dataChannel);
}

#pragma mark - RTCSessionDescriptionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error
{
    if (error) {
        DDLogError(@"Peer connection did create SDP: %@ with error: %@", sdp, error);
        return;
    }
    
    // Send an SDP.
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogVerbose(@"Peer connection did create %@", sdp.type);
        // Set the local description.
        
        //NBMVideoFormat videoFormat = self.mediaConfiguration.receiverVideoFormat;
        NBMVideoCodec videoCodec = self.mediaConfiguration.videoCodec;
        NSUInteger maxVideoBandwidth = self.mediaConfiguration.videoBandwidth;
        NBMAudioCodec audioCodec = self.mediaConfiguration.audioCodec;
        NSUInteger maxAudioBandwidth = self.mediaConfiguration.audioBandwidth;

        RTCSessionDescription *conditionedSDP = [NBMSessionDescriptionFactory conditionedSessionDescription:sdp
                                                                                                 audioCodec:audioCodec
                                                                                                 videoCodec:videoCodec
                                                                                             videoBandwidth:maxVideoBandwidth
                                                                                             audioBandwidth:maxAudioBandwidth];

        [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:conditionedSDP];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
    if (error) {
        DDLogError(@"Peer connection did set SDP with error: %@", error);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogVerbose(@"Peer connection did set session description: %@", peerConnection);
        NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
        if (!connection) {
            return;
        }
        
        if (peerConnection.iceGatheringState != RTCICEConnectionNew) {
            [connection drainRemoteCandidates];
        }
        
        //Send an Offer
        if (peerConnection.signalingState == RTCSignalingHaveLocalOffer) {
            RTCSessionDescription *sdpOffer = peerConnection.localDescription;
            [self.delegate webRTCPeer:self didGenerateOffer:sdpOffer forConnection:connection];
        }
        else if (peerConnection.signalingState == RTCSignalingHaveRemoteOffer) {
            // If we're answering and we've just set the remote offer we need to create
            // an answer and set the local description.
            RTCMediaConstraints *answerConstraints = [NBMSessionDescriptionFactory offerConstraints];
            [peerConnection createAnswerWithDelegate:self constraints:answerConstraints];
        }
        else if (peerConnection.signalingState == RTCSignalingStable) {
            if (!connection.isInitiator) {
                //An answer is generated
                RTCSessionDescription *sdpAnswer = peerConnection.localDescription;
                [self.delegate webRTCPeer:self didGenerateAnswer:sdpAnswer forConnection:connection];
            }
        }
    });
}

#pragma mark - RTCMediaStreamTrackDelegate

- (void)mediaStreamTrackDidChange:(RTCMediaStreamTrack *)mediaStreamTrack
{
    DDLogVerbose(@"Media stream track did change: %@", mediaStreamTrack);
}

@end
