//
//  NBMWebRTCPeer.h
//  Copyright (c) 2016 Telecom Italia S.p.A. All rights reserved.
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

#import <Foundation/Foundation.h>

#import "NBMTypes.h"
#import <WebRTC/RTCPeerConnection.h>

@class NBMWebRTCPeer;
@class NBMMediaConfiguration;
@class NBMPeerConnection;
@class RTCVideoTrack;
@class RTCMediaStream;
@class RTCSessionDescription;
@class RTCIceCandidate;

/**
 *  NBMWebRTCPeerDelegate is a protocol for an object that must be
 *  implemented to get messages from NBMWebRTCPeer.
 */
@protocol NBMWebRTCPeerDelegate <NSObject>

/**
 *  Called when the peer successfully generated an new offer for a connection.
 *
 *  @param peer       The peer sending the message.
 *  @param sdpOffer   The newly generated RTCSessionDescription offer.
 *  @param connection The connection for which the offer was generated.
 */
- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateOffer:(RTCSessionDescription *)sdpOffer forConnection:(NBMPeerConnection *)connection;

/**
 *  Called when the peer successfully generated a new answer for a connection.
 *
 *  @param peer       The peer sending the message.
 *  @param sdpAnswer  The newly generated RTCSessionDescription offer.
 *  @param connection The connection for which the aswer was generated.
 */
- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateAnswer:(RTCSessionDescription *)sdpAnswer forConnection:(NBMPeerConnection *)connection;

/**
 *  Called when a new ICE is locally gathered for a connection.
 *
 *  @param peer       The peer sending the message.
 *  @param candidate  The locally gathered ICE.
 *  @param connection The connection for which the ICE was gathered.
 */
- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCIceCandidate *)candidate forConnection:(NBMPeerConnection *)connection;

/**
 *  Called any time a connection's state changes.
 *
 *  @param peer       The peer sending the message.
 *  @param state      The new notified state.
 *  @param connection The connection whose state has changed.
 */
- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCIceConnectionState)state ofConnection:(NBMPeerConnection *)connection;

/**
 *  Called when media is received on a new stream from remote peer.
 *
 *  @param peer         The peer sending the message.
 *  @param remoteStream A RTCMediaStream instance.
 *  @param connection   The connection related to the stream.
 */
- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection;

/**
 *  Called when a remote peer close a stream.
 *
 *  @param peer         The peer sending the message.
 *  @param remoteStream A RTCMediaStream instance.
 *  @param connection   The connection related to the stream.
 */
- (void)webRTCPeer:(NBMWebRTCPeer *)peer didRemoveStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection;

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddDataChannel:(RTCDataChannel *)dataChannel;

@end

/**
 *  
 */
@interface NBMWebRTCPeer : NSObject

/**
 *  The media configuration object.
 */
@property (nonatomic, strong, readonly) NBMMediaConfiguration *mediaConfiguration;

/**
 *  The local stream.
 */
@property (nonatomic, strong, readonly) RTCMediaStream *localStream;

@property (nonatomic, assign, readonly) NBMCameraPosition cameraPosition;

/**
 *  The delegate object for the peer.
 */
@property (nonatomic, weak, readonly) id<NBMWebRTCPeerDelegate>delegate;

/**
 *  Initializes a new Web RTC peer manager.
 *
 *  @param delegate The delegate object for the peer manager.
 *  @param configuration A media configuration object.
 *
 *  @return An initialized Web RTC peer manager.
 */
- (instancetype)initWithDelegate:(id<NBMWebRTCPeerDelegate>)delegate configuration:(NBMMediaConfiguration *)configuration;

/**
 *  Create a new offer for connection with specified identifier.
 *
 *  @param connectionId The connection identifier.
 */
- (void)generateOffer:(NSString *)connectionId completion:(void(^)(NSString *sdpOffer, NBMPeerConnection *connection))block;

- (void)generateOffer:(NSString *)connectionId;

- (void)generateOffer:(NSString *)connectionId withDataChannels:(BOOL)dataChannels;

- (void)generateOffer:(NSString *)connectionId withDataChannels:(BOOL)dataChannels completion:(void(^)(NSString *sdpOffer, NBMPeerConnection *connection))block;

/**
 *  Process a remote offer for connection with specified identifier.
 *
 *  @param sdpOffer     The SDP offer.
 *  @param connectionId The connection identifier.
 */
- (void)processOffer:(NSString *)sdpOffer connectionId:(NSString *)connectionId;

/**
 *  Process a remote answer for connection with specified identifier.
 *
 *  @param sdpAnswer    The SDP answer.
 *  @param connectionId The connection identifier.
 */
- (void)processAnswer:(NSString *)sdpAnswer connectionId:(NSString *)connectionId;

/**
 *  Provides a remote candidate to ICE agent for connection with specified identifier.
 *
 *  @param candidate    A RTCICECandidate instance.
 *  @param connectionId The connection identifier.
 */
- (void)addICECandidate:(RTCIceCandidate *)candidate connectionId:(NSString *)connectionId;

/**
 *  Retrives a NBMPeerConnection instance with specified identifier.
 *
 *  @param connectionId The connection identifier.
 *
 *  @return A NBMPeerConnection instance, `nil` if no connection was found.
 */
- (NBMPeerConnection *)connectionWithConnectionId:(NSString *)connectionId;

/**
 *  Terminates all media and closes the transport of NBMPeerConnection with specified identifier.
 *
 *  @param connectionId The connection identifier.
 */
- (void)closeConnectionWithConnectionId:(NSString *)connectionId;

- (BOOL)startLocalMedia;

/**
 *  Terminates all media of active connections, removing the local stream.
 */
- (void)stopLocalMedia;

//- (NSArray *)connections;

- (NSArray *)activeConnections;

- (void)selectCameraPosition:(NBMCameraPosition)cameraPosition;

- (BOOL)hasCameraPositionAvailable:(NBMCameraPosition)cameraPosition;

- (BOOL)isVideoEnabled;
- (void)enableVideo:(BOOL)enable;
- (BOOL)isAudioEnabled;
- (void)enableAudio:(BOOL)enable;

- (BOOL)videoAuthorized;
- (BOOL)audioAuthorized;

@end
