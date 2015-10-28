//
//  NBMWebRTCPeer.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCTypes.h"

typedef NS_ENUM(NSUInteger, NBMCameraPosition)
{
    NBMCameraPositionAny = 0,
    NBMCameraPositionBack = 1,
    NBMCameraPositionFront = 2
};

@class NBMWebRTCPeer;
@class NBMPeerConnection;
@class RTCVideoTrack;
@class RTCMediaStream;
@class RTCSessionDescription;
@class RTCICECandidate;

@protocol NBMWebRTCPeerDelegate <NSObject>

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateOffer:(RTCSessionDescription *)sdpOffer forConnection:(NBMPeerConnection *)connection;
- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateAnswer:(RTCSessionDescription *)sdpAnswer forConnection:(NBMPeerConnection *)connection;
- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection;


//- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddLocalStream:(RTCMediaStream *)localStream;
- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCICEConnectionState)state ofConnection:(NBMPeerConnection *)connection;
- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection;
- (void)webRTCPeer:(NBMWebRTCPeer *)peer didRemoveStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection;

@end

@interface NBMWebRTCPeer : NSObject

@property (nonatomic, strong, readonly) RTCMediaStream *localStream;
@property (nonatomic, weak, readonly) id<NBMWebRTCPeerDelegate>delegate;

- (instancetype)initWithDelegate:(id<NBMWebRTCPeerDelegate>)delegate cameraPosition:(NBMCameraPosition)position;

//Generate/process SDP Offer
- (void)generateOffer:(NSString *)connectionId;
- (void)processOffer:(NSString *)sdpOffer connectionId:(NSString *)connectionId;

//Process SDP Answer
- (void)processAnswer:(NSString *)sdpAnswer connectionId:(NSString *)connectionId;

- (void)addICECandidate:(RTCICECandidate *)candidate connectionId:(NSString *)connectionId;

//Connections
- (NBMPeerConnection *)connectionWithConnectionId:(NSString *)connectionId;
- (void)closeConnectionWithConnectionId:(NSString *)connectionId;


@end
