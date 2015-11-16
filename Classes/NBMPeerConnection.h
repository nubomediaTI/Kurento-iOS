//
//  NBMPeerConnection.h
//  Kurento-iOS
//
//  Created by Marco Rossi on 12/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCPeerConnection;
@class RTCICECandidate;
@class RTCMediaStream;
@class RTCSessionDescription;

/**
 *
 */
@interface NBMPeerConnection : NSObject

/**
 *
 */
@property (nonatomic, copy) NSString *connectionId;
/**
 *
 */
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, assign) BOOL isInitiator;
@property (nonatomic, strong, readonly) NSMutableArray *queuedRemoteCandidates;
@property (nonatomic, strong) RTCSessionDescription *queuedOffer;
@property (nonatomic, strong) RTCMediaStream *remoteStream;
@property (nonatomic, assign) NSUInteger iceAttempts;

- (instancetype)initWithConnection:(RTCPeerConnection *)connection;
- (void)addIceCandidate:(RTCICECandidate *)candidate;
- (void)drainRemoteCandidates;
- (void)removeRemoteCandidates;

- (void)close;

@end
