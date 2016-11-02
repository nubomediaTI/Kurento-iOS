//
//  NBMTreeClient.h
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
