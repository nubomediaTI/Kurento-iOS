//
//  NBMWebRTCPeer.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCTypes.h"

/**
 *  Camera position types
 */
typedef NS_ENUM(NSUInteger, NBMCameraPosition) {
    /**
     *  Any camera position available.
     */
    NBMCameraPositionAny = 0,
    /**
     *  Back camera position.
     */
    NBMCameraPositionBack = 1,
    /**
     *  Front camera position.
     */
    NBMCameraPositionFront = 2
};

@class NBMWebRTCPeer;
@class NBMPeerConnection;
@class RTCVideoTrack;
@class RTCMediaStream;
@class RTCSessionDescription;
@class RTCICECandidate;

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
- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection;

/**
 *  Called any time a connection's state changes.
 *
 *  @param peer       The peer sending the message.
 *  @param state      The new notified state.
 *  @param connection The connection whose state has changed.
 */
- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCICEConnectionState)state ofConnection:(NBMPeerConnection *)connection;

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

@end

/**
 *  
 */
@interface NBMWebRTCPeer : NSObject

/**
 *  The local stream.
 */
@property (nonatomic, strong, readonly) RTCMediaStream *localStream;
/**
 *  The delegate object for the peer.
 */
@property (nonatomic, weak, readonly) id<NBMWebRTCPeerDelegate>delegate;

/**
 *  Initializes a new Web RTC peer manager.
 *
 *  @param delegate The delegate object for the peer manager.
 *  @param position The camera position used to capture video stream.
 *
 *  @return An initialized Web RTC peer manager.
 */
- (instancetype)initWithDelegate:(id<NBMWebRTCPeerDelegate>)delegate cameraPosition:(NBMCameraPosition)position;

/**
 *  Create a new offer for connection with specified identifier.
 *
 *  @param connectionId The connection identifier.
 */
- (void)generateOffer:(NSString *)connectionId;

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
- (void)addICECandidate:(RTCICECandidate *)candidate connectionId:(NSString *)connectionId;

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


@end
