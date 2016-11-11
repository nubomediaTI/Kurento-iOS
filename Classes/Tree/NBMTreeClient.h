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

@class NBMJSONRPCClient;
@class RTCIceCandidate;
@class NBMTreeEndpoint;
@protocol NBMTreeClientDelegate;

/**
 *  Tree client error codes.
 */
typedef NS_ENUM(NSInteger, NBMTreeClientErrorCode) {
    /**
     *  A generic error.
     */
    NBMTreeClientGenericErrorCode = 0,
    /**
     *  An error generated when an API request goes in timeout.
     */
    NBMTreeClientTimeoutErrorCode,
    /**
     *  An error related to WebSocket connection or malformed JSON-RPC response.
     */
    NBMTreeClientTransportErrorCode
};

typedef NS_ENUM(NSInteger, NBMTreeClientConnectionState) {
    // State when connecting.
    NBMTreeClientConnectionStateOpening,
    // State when connection is established and ready for use.
    NBMTreeClientConnectionStateOpen,
    // State when disconnecting.
    NBMTreeClientConnectionStateClosing,
    // State when disconnected.
    NBMTreeClientConnectionStateClosed
};

typedef NS_ENUM(NSInteger, NBMTreeMode) {
    NBMTreeModeNone,
    NBMTreeModeMaster,
    NBMTreeModeViewer
};

/**
 *  The developer of Kurento Tree applications can use this client when implementing the front-end part of a broadcasting application with Kurento Tree.
 *  It's actually only a wrapper over the JSON-RPC protocol used to communicate with Tree Server.
 */
@interface NBMTreeClient : NSObject

/**
 *  The delegate object for the client.
 */
@property (nonatomic, weak, readonly) id<NBMTreeClientDelegate> delegate;

@property (nonatomic, strong, readonly) NSURL *url;

/**
 *  A list of connected NBMTreeEndpoint objects.
 */
@property (nonatomic, readonly) NSSet *treeEndpoints;

/**
 *  The timeout interval for API requests, in seconds.
 *  Default value is 5.
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeout;

@property (nonatomic, assign, readonly) NBMTreeClientConnectionState connectionState;

/**
 *  A Boolean that indicates the WebSocket connection status.
 */
@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;

/**
 *  The identifier of current tree.
 */
@property (nonatomic, copy, readonly) NSString *treeId;

/**
 *  The tree mode (Master/Viewer). None if the client is not acting as master or viewer.
 */
@property (nonatomic, assign, readonly) NBMTreeMode treeMode;

/**
 *  Creates and initializes a NBMTreeClient instance.
 *
 *  @param wsURL    The url of Tree server.
 *  @param delegate The delegate object for the client.
 
 *  @return An initialized NBMTreeClient object.
 */
- (instancetype)initWithURL:(NSURL *)wsURL delegate:(id<NBMTreeClientDelegate>)delegate;

/**
 *  Connects client to the Tree Server using WebSocket, giving access to its API when the connection is
 *  established successfully.
 *  @note See [NBMTreeClientDelegate client:isConnected:] method.
 *
 *  @param timeout The timeout interval for API requests, in seconds.
 */
- (void)connect:(NSTimeInterval)timeout;


- (void)connect;

/**
 *  Request to create a new tree in Tree server.
 *
 *  @param treeId The tree identifier. May be nil.
 *  @param block  A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)createTree:(NSString *)treeId completion:(void (^)(NSError *error))block;

/**
 *  Request used to remove a tree.
 *
 *  @param treeId Tree id to be removed
 *  @param block  A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)releaseTree:(NSString *)treeId completion:(void (^)(NSError *error))block;

/**
 *  Request to configure the emitter (source) in a broadcast session (tree).
 *
 *  @param sdpOffer A NSString representing an SDP offer.
 *  @param treeId   Tree id to configure the source.
 *  @param block    A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)setSource:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void (^)(NSString *sdpAnswer, NSError *error))block;

/**
 *  Request to remove the current emitter of a tree.
 *
 *  @param treeId Tree id to remove the source.
 *  @param block  A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)removeSourceOfTree:(NSString *)treeId completion:(void (^)(NSError *error))block;

/**
 *  Request to add a new viewer (sink) to the tree.
 *
 *  @param sdpOffer A NSString representing an SDP offer.
 *  @param treeId   Tree id to add new viewer.
 *  @param block    A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)addSink:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void(^)(NBMTreeEndpoint *endpoint, NSError *error))block;

/**
 *  Request to remove a previously connected sink (viewer).
 *
 *  @param sinkId Sink id to be removed.
 *  @param treeId Tree id to remove the sink.
 *  @param block  A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)removeSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void(^)(NSError *error))block;

/**
 *  Request used to add a new ICE candidate gathered on the client side. This information is required to implement the trickle ICE mechanism.
 *
 *  @param candidate The RTCICECandidate object to send.
 *  @param sinkId    Sink id to wich belongs the candidate, 'nil' if the candidate is referred to the tree source.
 *  @param treeId    Tree id to which belongs this candidate.
 *  @param block     A block object to be executed when the request is processed. This block has no return value and takes an error if the request failed.
 */
- (void)sendICECandidate:(RTCIceCandidate *)candidate forSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void(^)(NSError *error))block;

@end
