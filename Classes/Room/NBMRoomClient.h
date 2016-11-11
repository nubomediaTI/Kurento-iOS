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

#import <Foundation/Foundation.h>

@class NBMRoom;
@class NBMPeer;
@class RTCIceCandidate;
@protocol NBMRoomClientDelegate;

/**
 *  Room Client error types.
 */
typedef NS_ENUM(NSInteger, NBMRoomClientErrorCode) {
    /**
     *  Describes a generic error.
     */
    NBMRoomClientGenericErrorCode = 0,
    /**
     *  An error generated when a request goes in timeout.
     */
    NBMRoomClientTimeoutErrorCode
};

typedef NS_ENUM(NSInteger, NBMRoomClientConnectionState) {
    // State when connecting.
    NBMRoomClientConnectionStateOpening,
    // State when connection is established and ready for use.
    NBMRoomClientConnectionStateOpen,
    // State when disconnecting.
    NBMRoomClientConnectionStateClosing,
    // State when disconnected.
    NBMRoomClientConnectionStateClosed
};

/**
 *  It's actually only a wrapper over the JSON-RPC protocol used to communicate with Room Server.
 *  The developer of room applications can use this API when implementing an iOS client.
 */
@interface NBMRoomClient : NSObject

/**
 *  The delegate object for the client.
 */
@property (nonatomic, weak) id<NBMRoomClientDelegate> delegate;

/**
 *  A list of connected NBMPeer objects.
 */
@property (nonatomic, readonly) NSArray *peers;

/**
 *  The NBMRoom instance representing the joined room.
 */
@property (nonatomic, readonly) NBMRoom *room;

/**
 *  The timeout interval for API requests, in seconds.
 *  Default value is 5.
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeout;

@property (nonatomic, assign, readonly) NBMRoomClientConnectionState connectionState;

/**
 *  A Boolean that indicates the WebSocket connection status.
 */
@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;

/**
 *  A Boolean that indicates if the room was joined by the local peer.
 */
@property (nonatomic, assign, readonly, getter = isJoined) BOOL joined;

/**
 *  Creates and initializes a NBMRoomClient with default API timeout interval.
 *
 *  @param room     The room to join with.
 *  @param delegate The delegate object for the client
 *
 *  @return An initialized NBMRoomClient object.
 */
- (instancetype)initWithRoom:(NBMRoom *)room delegate:(id<NBMRoomClientDelegate>)delegate;

/**
 *  Creates and initializes a NBMRoomClient with a custom API timeout interval.
 *
 *  @param room     The room to join with.
 *  @param timeout  The timeout interval for API requests, in seconds.
 *  @param delegate The delegate object for the client.
 *
 *  @return An initialized NBMRoomClient object.
 */
- (instancetype)initWithRoom:(NBMRoom *)room timeout:(NSTimeInterval)timeout delegate:(id<NBMRoomClientDelegate>)delegate;

/**
 *  Connects client to the Room Server using WebSocket, giving access to its API when the connection is
 *  established successfully.
 *  @note See [NBMRoomClientDelegate client:isConnected:] method.
 */
- (void)connect;

- (void)disconnect;

/**
 *  Represents a client's request to join a room. If the room does not exists, it is created.
 *  When the request is processed, the [NBMRoomClientDelegate client:didJoinRoom:] message is sent to the client's delegate.
 */
- (void)joinRoom;

- (void)joinRoomWithDataChannels:(BOOL)dataChannels;

/**
 *  Represents a client's request to join a room. If the room does not exists, it is created.
 *  @note No message is sent to client's delegate.
 *  
 *  @param block A block object to be executed when the request is processed. This block has no return value and takes an NSSet of remote participants and an error if the request failed.
 */
- (void)joinRoom:(void (^)(NSSet *peers, NSError *error))block;

- (void)joinRoom:(void (^)(NSSet *peers, NSError *error))completionBlock dataChannels:(BOOL)dataChannels;

/**
 *  Represent a client's notification that it's leaving the room.
 *  When the request is processed, the [NBMRoomClientDelegate client:didLeaveRoom:] message is sent to the client's delegate.
 */
- (void)leaveRoom;

/**
 *  Represent a client's notification that it's leaving the room.
 *  @note No message is sent to client's delegate.
 *
 *  @param block A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)leaveRoom:(void (^)(NSError *error))block;

/**
 *  Represents a client’s request to start streaming her local media to anyone inside the room.
 *  When the request is processed, the [NBMRoomClientDelegate client:didPublishVideo:loopback:error:] message is sent to the client's delegate.
 *
 *  @param sdpOffer   A NSString representing an SDP offer.
 *  @param doLoopback A Boolean enabling media loopback.
 */
- (void)publishVideo:(NSString *)sdpOffer loopback:(BOOL)doLoopback;

/**
 *  Represents a client’s request to start streaming her local media to anyone inside the room.
 *  @note No message is sent to client's delegate.
 *
 *  @param sdpOffer   A NSString representing an SDP offer.
 *  @param doLoopback A Boolean enabling media loopback.
 *  @param block      A block object to be executed when the request is processed. This block has no return value and takes the SDP answer sent by KMS and an error if the request failed.
 */
- (void)publishVideo:(NSString *)sdpOffer loopback:(BOOL)doLoopback completion:(void (^)(NSString *sdpAnswer, NSError *error))block;

/**
 *  Represents a client’s request to stop streaming its local media to the room peers.
 *  When the request is processed, the [NBMRoomClientDelegate client:didUnPublishVideo:] message is sent to the client's delegate.
 */
- (void)unpublishVideo;

/**
 *  Represents a client’s request to stop streaming its local media to the room peers.
 *  @note No message is sent to client's delegate.
 *
 *  @param block A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)unpublishVideo:(void (^)(NSError *error))block;

/**
 *  Represents a client’s request to receive media from participants in the room that published their media. 
 *  This method can also be used for loopback connections.
 *  When the request is processed, the [NBMRoomClientDelegate client:didReceiveVideoFrom:sdpAnswer:error:] message is sent to the client's delegate.
 *
 *  @param peer     A NBMPeer that is publishing media.
 *  @param sdpOffer A NSString representing an SDP offer.
 */
- (void)receiveVideoFromPeer:(NBMPeer *)peer offer:(NSString *)sdpOffer;

/**
 *  Represents a client’s request to receive media from participants in the room that published their media.
 *  @note No message is sent to client's delegate.
 *
 *  @param peer     A NBMPeer that is publishing media.
 *  @param sdpOffer A NSString representing an SDP offer.
 *  @param block    A block object to be executed when the request is processed. This block has no return value and takes the SDP answer sent by KMS and an error if the request failed.
 */
- (void)receiveVideoFromPeer:(NBMPeer *)peer offer:(NSString *)sdpOffer completion:(void (^)(NSString *sdpAnswer, NSError *error))block;

/**
 *  Represents a client’s request to stop receiving media from a given publisher.
 *  When the request is processed, the [NBMRoomClientDelegate client:didUnsubscribeVideoFrom:sdpAnswer:error:] message is sent to the client's delegate.
 *
 *  @param peer A NBMPeer that is publishing media.
 */
- (void)unsubscribeVideoFromPeer:(NBMPeer *)peer;

/**
 *  Represents a client’s request to stop receiving media from a given publisher.
 *  @note No message is sent to client's delegate.
 *
 *  @param peer  The NBMPeer that is publishing media.
 *  @param block A block object to be executed when the request is processed. This block has no return value and takes the SDP answer sent by KMS and an error if the request failed.
 */
- (void)unsubscribeVideoFromPeer:(NBMPeer *)peer completion:(void (^)(NSString *sdpAnswer, NSError *error))block;

/**
 *  Request that carries info about an ICE candidate gathered on the client side. This information is required to implement the trickle ICE mechanism.
 *  When the request is processed, the [NBMRoomClientDelegate client:didUnsubscribeVideoFrom:sdpAnswer:error:] message is sent to the client's delegate.
 *
 *  @param candidate The RTCICECandidate object to send.
 *  @param peer      The NBMPeer whose ICE candidate was found.
 */
- (void)sendICECandidate:(RTCIceCandidate *)candidate forPeer:(NBMPeer *)peer;

/**
 *  Request that carries info about an ICE candidate gathered on the client side. This information is required to implement the trickle ICE mechanism.
 *  @note No message is sent to client's delegate.
 *
 *  @param candidate The RTCICECandidate object to send.
 *  @param peer      The NBMPeer whose ICE candidate was found.
 *  @param block     A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)sendICECandidate:(RTCIceCandidate *)candidate forPeer:(NBMPeer *)peer completion:(void (^)(NSError *error))block;

/**
 *  Represents a client's request to send written message to all other participants in the room.
 *  When the request is processed, the [NBMRoomClientDelegate client:didSentMessage:] message is sent to the client's delegate.
 *
 *  @param message The text message.
 */
- (void)sendMessage:(NSString *)message;

/**
 *  Represents a client's request to send written message to all other participants in the room.
 *  @note No message is sent to client's delegate.
 *
 *  @param message The text message.
 *  @param block   A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)sendMessage:(NSString *)message completion:(void (^)(NSError *error))block;

/**
 *  Provides a custom envelope for requests not directly implemented by the Room server.
 *  When the request is processed, the [NBMRoomClientDelegate client:didSentCustomRequest:] message is sent to the client's delegate.
 *
 *  @param params A NSDictionary of NSString key-value parameters, their specification is left to the actual implementation.
 */
- (void)sendCustomRequest:(NSDictionary<NSString *, NSString *>*)params;

/**
 *  Provides a custom envelope for requests not directly implemented by the Room server.
 *  @note No message is sent to client's delegate.
 *
 *  @param params A NSDictionary of NSString key-value parameters, their specification is left to the actual implementation.
 *  @param block  A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)sendCustomRequest:(NSDictionary <NSString *, NSString *>*)params completion:(void (^)(NSError *error))block;

/**
 *  Returns a remote NBMPeer with specified identifier, if exists.
 *
 *  @param identifier A unique NSString identifier (peer's username).
 *
 *  @return a NBMPeer object with specified identifier.
 */
- (NBMPeer *)peerWithIdentifier:(NSString *)identifier;

@end
