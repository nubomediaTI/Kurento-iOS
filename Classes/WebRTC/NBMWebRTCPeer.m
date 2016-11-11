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

#import "NBMWebRTCPeer.h"
#import "NBMLog.h"

#import "NBMSessionDescriptionFactory.h"
#import "NBMMediaConfiguration.h"
#import "NBMPeerConnection.h"

#import <AVFoundation/AVFoundation.h>

#import "RTCMediaStream+Configuration.h"

//Web-RTC classes
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCSessionDescription.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCAVFoundationVideoSource.h>
#import <WebRTC/RTCDataChannelConfiguration.h>
#import <WebRTC/RTCDataChannel.h>

typedef void(^SdpOfferBlock)(NSString *sdpOffer, NBMPeerConnection *connection);
static NSString *kDefaultSTUNServerUrl = @"stun:stun.l.google.com:19302";

@interface NBMWebRTCPeer () <RTCPeerConnectionDelegate, RTCDataChannelDelegate>

@property (nonatomic, strong) NSMutableArray *iceServers;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) NSMutableDictionary *connectionMap;
@property (nonatomic, strong) NBMPeerConnection *localPeerConnection;
@property (nonatomic, strong) RTCDataChannel *dataChannel;
@property (nonatomic, strong) RTCMediaStream *localStream;
@property (nonatomic, assign, readwrite) NBMCameraPosition cameraPosition;

@property (nonatomic, copy) SdpOfferBlock offerBlock;

@end

@implementation NBMWebRTCPeer

#pragma mark - Public

- (instancetype)initWithDelegate:(id<NBMWebRTCPeerDelegate>)delegate configuration:(NBMMediaConfiguration *)configuration
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _mediaConfiguration = configuration;
        //[RTCPeerConnectionFactory initialize];
        _peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
        _iceServers = [NSMutableArray arrayWithObject:[self defaultSTUNServer]];
        _connectionMap = [NSMutableDictionary dictionary];
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
        connection = [self connectionWrapperWithConnectionId:connectionId servers:_iceServers];
    }
    connection.isInitiator = NO;

    RTCSessionDescription *description = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:sdpOffer];
    __block __weak RTCPeerConnection* peerConnection = connection.peerConnection;
    [connection.peerConnection setRemoteDescription:description completionHandler:^(NSError * _Nullable error) {
        [self peerConnection:peerConnection didSetSessionDescriptionWithError:error];
    }];
    //[connection.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:description];
    
    self.connectionMap[connectionId] = connection;
    
    //TODO:Renegotiate active connections
}

- (void)generateOffer:(NSString *)connectionId completion:(void(^)(NSString *sdpOffer, NBMPeerConnection *connection))block {
    [self generateOffer:connectionId withDataChannels:NO completion:block];
}

- (void)generateOffer:(NSString *)connectionId {
    [self generateOffer:connectionId withDataChannels:NO];
}

- (void)generateOffer:(NSString *)connectionId withDataChannels:(BOOL)dataChannels completion:(void(^)(NSString *sdpOffer, NBMPeerConnection *connection))block {
    self.offerBlock = block;
    [self generateOffer:connectionId withDataChannels:dataChannels];
}

- (void)generateOffer:(NSString *)connectionId withDataChannels:(BOOL)dataChannels {
    NSParameterAssert(connectionId);
    
//    if (!self.localStream) {
//        [self startLocalMedia];
//    }
   
    NBMPeerConnection *connection = self.connectionMap[connectionId];
//    if (connection) {
//        DDLogWarn(@"Connection already exixts - id: %@", connectionId);
//        return;
//    }
    if (!connection) {
        connection = [self connectionWrapperWithConnectionId:connectionId servers:_iceServers];
    }
    connection.isInitiator = YES;
    RTCMediaConstraints *constraints = [NBMSessionDescriptionFactory offerConstraints];
    __block RTCPeerConnection* peerConnection = connection.peerConnection;
    
    BOOL isLocalPeerConnection = [[self.connectionMap allKeys] count] == 0;
    if (!self.localPeerConnection && isLocalPeerConnection) {
        self.localPeerConnection = connection;
        
        if (dataChannels) {
            RTCDataChannelConfiguration* config = [[RTCDataChannelConfiguration alloc] init];
            config.isNegotiated = NO;
            NSString *label = @"webcam_0";
            _dataChannel = [peerConnection dataChannelForLabel:label configuration:config];
            [_dataChannel setDelegate:self];
        }
    }

    [connection.peerConnection offerForConstraints:constraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        [self peerConnection:peerConnection didCreateSessionDescription:sdp error:error];
    }];
    //[connection.peerConnection createOfferWithDelegate:self constraints:constraints];

    self.connectionMap[connectionId] = connection;
    
    //TODO:Renegotiate active connections
}

/** The data channel state changed. */
- (void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel {
    DDLogVerbose(@"Data channel changed state: @%, %@", dataChannel.label, dataChannel.readyState);
    
    if (dataChannel.readyState == RTCDataChannelStateOpen) {
        [self.delegate webRTCPeer:self didAddDataChannel:dataChannel];
    }
}

/** The data channel successfully received a data buffer. */
- (void)dataChannel:(RTCDataChannel *)dataChannel
didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer {
    
}

//- (void)generateOffer:(NSString *)connectionId restartICE:(BOOL)restart {
//    
//}

- (void)processAnswer:(NSString *)sdpAnswer connectionId:(NSString *)connectionId {
    //NSParameterAssert(sdpAnswer);
    NSParameterAssert(connectionId);
    
    NBMPeerConnection *connection = self.connectionMap[connectionId];
    __block __weak RTCPeerConnection* peerConnection = connection.peerConnection;
    RTCSessionDescription *description = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdpAnswer];
    [connection.peerConnection setRemoteDescription:description completionHandler:^(NSError * _Nullable error) {
        [self peerConnection:peerConnection didSetSessionDescriptionWithError:error];
    }];
    //[connection.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:description];
}

- (void)addICECandidate:(RTCIceCandidate *)candidate connectionId:(NSString *)connectionId {
    NSParameterAssert(candidate);
    NSParameterAssert(connectionId);
    
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
//    NSArray *connections = [self.connectionMap allValues];
//    for (NBMPeerConnection *connection in connections) {
//        [connection close];
//    }
//    [self.connectionMap removeAllObjects];
    
//    self.localPeerConnection = nil;
    
    [self.localStream removeAudioTrack:[self.localStream.audioTracks firstObject]];
    [self.localStream removeVideoTrack:[self.localStream.videoTracks firstObject]];
    
    self.localStream = nil;
}


- (NBMCameraPosition)cameraPosition {
    return self.mediaConfiguration.cameraPosition;
}

- (void)setCameraPosition:(NBMCameraPosition)cameraPosition {
    self.mediaConfiguration.cameraPosition = cameraPosition;
}

- (void)selectCameraPosition:(NBMCameraPosition)cameraPosition {
    if (self.cameraPosition != cameraPosition) {
        self.cameraPosition = cameraPosition;
        [self setupLocalVideo];
        RTCPeerConnection *localPeerConnection = self.localPeerConnection.peerConnection;
        if (localPeerConnection) {
            RTCMediaStream *oldLocalStream = [localPeerConnection.localStreams firstObject];
            [localPeerConnection removeStream:oldLocalStream];
            [localPeerConnection addStream:self.localStream];
        }
    }
}

- (BOOL)hasCameraPositionAvailable:(NBMCameraPosition)cameraPosition {
    NSString *cameraDevice = [self cameraDevice:cameraPosition];

    return cameraDevice ? YES : NO;
}

- (BOOL)isVideoEnabled {
    return self.localStream.videoEnabled;
}

- (void)enableVideo:(BOOL)enable {
    [self.localStream setVideoEnabled:enable];
}

- (BOOL)isAudioEnabled {
    return self.localStream.audioEnabled;
}

- (void)enableAudio:(BOOL)enable {
    [self.localStream setAudioEnabled:enable];
}

- (BOOL)videoAuthorized {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        return YES;
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
    }
    
    return NO;
}

- (BOOL)audioAuthorized {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        return YES;
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
    }
    
    return NO;
}

- (NSArray *)activeConnections
{
    NSSet *keys = [self.connectionMap keysOfEntriesPassingTest:^BOOL(NSString *connectionId, NBMPeerConnection *connection, BOOL *stop) {
        RTCPeerConnection *rtcConnection = connection.peerConnection;
        if (rtcConnection.signalingState == RTCSignalingStateStable && rtcConnection.iceConnectionState != RTCIceConnectionStateFailed) {
            return YES;
        }
        return NO;
    }];
    
    return [self.connectionMap objectsForKeys:[keys allObjects] notFoundMarker:[NSNull null]];
}

#pragma mark - Private

- (NSUInteger)connectionCount
{
    return [self.connectionMap count];
}

- (NSUInteger)activeConnectionCount
{
    return [[self activeConnections] count];
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
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    [config setIceServers:iceServers];
    RTCPeerConnection *connection = [self.peerConnectionFactory peerConnectionWithConfiguration:config constraints:constraints delegate:self];
    
    if (self.localStream) {
        [connection addStream:self.localStream];
    }
    
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

- (NSString *)localStreamLabel {
    return @"ARDAMS";
}

- (NSString *)audioTrackId {
    return [[self localStreamLabel] stringByAppendingString:@"a0"];
}

- (NSString *)videoTrackId {
    return [[self localStreamLabel] stringByAppendingString:@"v0"];
}

- (BOOL)startLocalMedia
{
    RTCMediaStream *localMediaStream = [_peerConnectionFactory mediaStreamWithStreamId:[self localStreamLabel]];
    self.localStream = localMediaStream;
    
    //Audio setup
    BOOL audioEnabled = NO;
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioAuthStatus == AVAuthorizationStatusAuthorized || audioAuthStatus == AVAuthorizationStatusNotDetermined) {
        audioEnabled = YES;
        [self setupLocalAudio];
    }
    
    //Video setup
    BOOL videoEnabled = NO;
    // The iOS simulator doesn't provide any sort of camera capture
    // support or emulation (http://goo.gl/rHAnC1) so don't bother
    // trying to open a local video track.
#if !TARGET_IPHONE_SIMULATOR
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoAuthStatus == AVAuthorizationStatusAuthorized || videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        videoEnabled = YES;
        [self setupLocalVideo];
    }
    
#endif
    
    return audioEnabled && videoEnabled;
}

- (void)setupLocalMediaWithVideoConstraints:(RTCMediaConstraints *)videoConstraints
{
    RTCMediaStream *localMediaStream = [_peerConnectionFactory mediaStreamWithStreamId:[self localStreamLabel]];
    self.localStream = localMediaStream;
    
    //Audio setup
    [self setupLocalAudio];

    // The iOS simulator doesn't provide any sort of camera capture
    // support or emulation (http://goo.gl/rHAnC1) so don't bother
    // trying to open a local video track.
#if !TARGET_IPHONE_SIMULATOR
    //Video setup
    [self setupLocalVideo];
    
#endif
}

- (void)setupLocalAudio {
    RTCAudioTrack *audioTrack = [self.peerConnectionFactory audioTrackWithTrackId:[self audioTrackId]];
    if (self.localStream && audioTrack) {
        [self.localStream addAudioTrack:audioTrack];
    }
}

- (void)setupLocalVideo {
    [self setupLocalVideoWithConstraints:nil];
}

- (void)setupLocalVideoWithConstraints:(RTCMediaConstraints *)videoConstraints {
    RTCVideoTrack *videoTrack = [self localVideoTrackWithConstraints:videoConstraints];
    if (self.localStream && videoTrack) {
        RTCVideoTrack *oldVideoTrack = [self.localStream.videoTracks firstObject];
        if (oldVideoTrack) {
            [self.localStream removeVideoTrack:oldVideoTrack];
        }
        [self.localStream addVideoTrack:videoTrack];
    }
}

- (RTCVideoTrack *)localVideoTrackWithConstraints:(RTCMediaConstraints *)videoConstraints {
    NSString *cameraId = [self cameraDevice:self.cameraPosition];
    
    NSAssert(cameraId, @"Unable to get camera id");
    
    RTCAVFoundationVideoSource* videoSource = [self.peerConnectionFactory avFoundationVideoSourceWithConstraints:videoConstraints];
    if (self.cameraPosition == NBMCameraPositionBack) {
        [videoSource setUseBackCamera:YES];
    }
    
    RTCVideoTrack *videoTrack = [self.peerConnectionFactory videoTrackWithSource:videoSource trackId:[self videoTrackId]];
    
    return videoTrack;
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
        case RTCSignalingStateStable:
            return @"Stable";
            break;
        case RTCSignalingStateHaveLocalOffer:
            return @"Have Local Offer";
            break;
        case RTCSignalingStateHaveRemoteOffer:
            return @"Have Remote Offer";
            break;
        case RTCSignalingStateClosed:
            return @"Closed";
            break;
        default:
            return @"Other state";
            break;
    }
}

- (NSString *)stringForConnectionState:(RTCIceConnectionState)state
{
    switch (state) {
        case RTCIceConnectionStateNew:
            return @"New";
            break;
        case RTCIceConnectionStateChecking:
            return @"Checking";
            break;
        case RTCIceConnectionStateConnected:
            return @"Connected";
            break;
        case RTCIceConnectionStateCompleted:
            return @"Completed";
            break;
        case RTCIceConnectionStateFailed:
            return @"Failed";
            break;
        case RTCIceConnectionStateDisconnected:
            return @"Disconnected";
            break;
        case RTCIceConnectionStateClosed:
            return @"Closed";
            break;
        default:
            return @"Other state";
            break;
    }
}

- (NSString *)stringForGatheringState:(RTCIceGatheringState)state
{
    switch (state) {
        case RTCIceGatheringStateNew:
            return @"New";
            break;
        case RTCIceGatheringStateGathering:
            return @"Gathering";
            break;
        case RTCIceGatheringStateComplete:
            return @"Complete";
            break;
        default:
            return @"Other state";
            break;
    }
}

- (void)dealloc {
    _connectionMap = nil;
    _dataChannel = nil;
    _localPeerConnection = nil;
    _localStream = nil;
    _peerConnectionFactory = nil;
}

#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection
 didChangeSignalingState:(RTCSignalingState)stateChanged {
    NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
    DDLogVerbose(@"Peer connection %@ - signaling state changed: %@", connection.connectionId, [self stringForSignalingState:stateChanged]);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
           didAddStream:(RTCMediaStream *)stream {
    NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
    DDLogVerbose(@"Peer connection %@ - received %lu video tracks and %lu audio tracks",
                 connection.connectionId, (unsigned long)stream.videoTracks.count, (unsigned long)stream.audioTracks.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connection) {
            return;
        }
        connection.remoteStream = stream;

        [self.delegate webRTCPeer:self didAddStream:stream ofConnection:connection];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
         didRemoveStream:(RTCMediaStream *)stream {
    NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
    DDLogVerbose(@"Peer connection %@ - stream was removed", connection.connectionId);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connection) {
            return;
        }
        connection.remoteStream = nil;
        
        [self.delegate webRTCPeer:self didRemoveStream:stream ofConnection:connection];
    });
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
    DDLogVerbose(@"Peer connection %@ - renegotiation needed but unimplemented", connection.connectionId);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
  didChangeIceConnectionState:(RTCIceConnectionState)newState {
    NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
    DDLogVerbose(@"Peer connection %@ - ICE state changed: %@", connection.connectionId, [self stringForConnectionState:newState]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connection) {
            return;
        }
        
        if (newState == RTCIceConnectionStateFailed) {
            connection.iceAttempts++;
            [connection removeRemoteCandidates];
        }
        else if (newState == RTCIceConnectionStateConnected) {
            connection.iceAttempts = 0;
        }
        
        [self.delegate webrtcPeer:self iceStatusChanged:newState ofConnection:connection];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
   didChangeIceGatheringState:(RTCIceGatheringState)newState {
    NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
    DDLogVerbose(@"Peer connection %@ - ICE gathering state changed: %@", connection.connectionId, [self stringForGatheringState:newState]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (newState == RTCIceGatheringStateGathering) {
            //Is this check needed?
            if (peerConnection.iceGatheringState == RTCIceGatheringStateGathering) {
                [connection drainRemoteCandidates];
            }
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    NBMPeerConnection *connection = [self wrapperForConnection:peerConnection];
    DDLogVerbose(@"Peer connection %@ - got ICE candidate", connection.connectionId);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connection) {
            return;
        }
        
        [self.delegate webRTCPeer:self hasICECandidate:candidate forConnection:connection];
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel {

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

        __block __weak RTCPeerConnection* weakPeerConnection = peerConnection;
        [peerConnection setLocalDescription:conditionedSDP completionHandler:^(NSError * _Nullable error) {
            [self peerConnection:weakPeerConnection didSetSessionDescriptionWithError:error];
        }];
        //[peerConnection setLocalDescriptionWithDelegate:self sessionDescription:conditionedSDP];
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
        
        if (peerConnection.iceGatheringState != RTCIceConnectionStateNew) {
            [connection drainRemoteCandidates];
        }
        
        //Send an Offer
        if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer) {
            RTCSessionDescription *sdpOffer = peerConnection.localDescription;
            if (self.offerBlock) {
                self.offerBlock(sdpOffer.sdp, connection);
                self.offerBlock = nil;
                return;
            }
            [self.delegate webRTCPeer:self didGenerateOffer:sdpOffer forConnection:connection];
        }
        else if (peerConnection.signalingState == RTCSignalingStateHaveRemoteOffer) {
            // If we're answering and we've just set the remote offer we need to create
            // an answer and set the local description.
            RTCMediaConstraints *answerConstraints = [NBMSessionDescriptionFactory offerConstraints];
            [peerConnection answerForConstraints:answerConstraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
                [self peerConnection:peerConnection didSetSessionDescriptionWithError:error];
            }];
            //[peerConnection createAnswerWithDelegate:self constraints:answerConstraints];
        }
        else if (peerConnection.signalingState == RTCSignalingStateStable) {
            if (!connection.isInitiator) {
                //An answer is generated
                RTCSessionDescription *sdpAnswer = peerConnection.localDescription;
                [self.delegate webRTCPeer:self didGenerateAnswer:sdpAnswer forConnection:connection];
            }
        }
    });
}

- (RTCIceServer *)defaultSTUNServer {
    return [[RTCIceServer alloc] initWithURLStrings:@[kDefaultSTUNServerUrl]
                                           username:@""
                                         credential:@""];
}

@end
