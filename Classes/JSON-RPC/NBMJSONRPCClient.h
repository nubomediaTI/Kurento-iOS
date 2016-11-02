//
//  NBMJSONRPCClient.h
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

@class NBMRequest, NBMResponse, NBMResponseError;
@protocol NBMJSONRPCClientDelegate;

/**
 *  NBMJSONRPCClientConfiguration object used to configure NBJSONRPCClient.
 */
@interface NBMJSONRPCClientConfiguration : NSObject

/**
 *  The timeout interval for the new request, in seconds.
 *  Default value is 5.
 */
@property (nonatomic) NSTimeInterval requestTimeout;
/**
 *  The retry number for requests gone in timeout (with no response back).
 *  Default value is 1.
 */
@property (nonatomic) NSUInteger requestMaxRetries;

/**
 *  A boolean that determines whether the client needs to connect automatically after initialization.
 *  Default value is YES.
 */
@property (nonatomic, assign) BOOL autoConnect;

/**
 *  A configuration object with deafult values used to configure NBJSONRPCClient.
 *
 *  @return A newly initialized NBMJSONRPCClientConfiguration object.
 */
+ (instancetype)defaultConfiguration;

@end

typedef NS_ENUM(NSInteger, NBMJSONRPCConnectionState) {
    // State when connecting.
    NBMJSONRPCConnectionStateOpening,
    // State when connection is established and ready for use.
    NBMJSONRPCConnectionStateOpen,
    // State when disconnecting.
    NBMJSONRPCConnectionStateClosing,
    // State when disconnected.
    NBMJSONRPCConnectionStateClosed
};

/**
 *  NBMJSONRPCClient object communicates with web sockets using the JSON-RPC 2.0 protocol.
 *  @see http://www.jsonrpc.org/specification
 */
@interface NBMJSONRPCClient : NSObject

typedef NS_ENUM(NSInteger, NBMJSONRPCClientErrorCode) {
    NBMJSONRPCClientGenericErrorCode,
    NBMJSONRPCClientInitializationErrorCode,
};

/**
 *  The URL for the websocket.
 */
@property (nonatomic) NSURL *url;

/**
 *  The client configuration object.
 */
@property (nonatomic, readonly) NBMJSONRPCClientConfiguration *configuration;

/**
 * The delegate object for the client.
 */
@property (nonatomic, weak) id<NBMJSONRPCClientDelegate>delegate;

@property (nonatomic, readonly) NBMJSONRPCConnectionState connectionState;

/**
 * A boolean that indicates the websocket connection status.
 */
@property (nonatomic, readonly, getter=isConnected) BOOL connected;

/**
 *  Creates and initializes a JSON-RPC client with the specified endpoint using default configuration.
 *
 *  @param url      The endpoint URL.
 *  @param delegate The delegate object for the client.
 *
 *  @return An initialized JSON-RPC client.
 */
- (instancetype)initWithURL:(NSURL *)url delegate:(id<NBMJSONRPCClientDelegate>)delegate;

/**
 *  Creates and initializes a JSON-RPC client with the specified endpoint using provided configuration.
 *
 *  @param url The endpoint URL.
 *  @param configuration  A configuration object.
 *  @param delegate The delegate object for the client.
 *
 *  @return An initialized JSON-RPC client.
 */
- (instancetype)initWithURL:(NSURL *)url configuration:(NBMJSONRPCClientConfiguration *)configuration delegate:(id<NBMJSONRPCClientDelegate>)delegate;

/**
 * Connects client to the server using WebSocket. 
 * @note Use this method after initialization when <autoConnect> configuration's property is set to NO or when connection goes down and <connected> property switch to NO.
 */
- (void)connect;

/**
 *  Creates and sends a request with the specified method using websocket as transport channel.
 *
 *  @param method        The request method. Must not be `nil`.
 *  @param responseBlock A block object to be executed when the request is sent. This block has no return value and takes the response object created by the client
 *  response serializer. The response object may be `nil` if network (e.g timeout) or parsing error occurred.
 *
 *  @return The `NBMRequest` object that was sent.
 */
- (NBMRequest *)sendRequestWithMethod:(NSString *)method
                           completion:(void (^)(NBMResponse *response))responseBlock;

/**
 *  Creates and sends a request with the specified method and parameters using websocket as transport channel.
 *
 *  @param method        The request method. Musto not be `nil`.
 *  @param parameters    The parameters to encode into the request. Must be either an `NSDictionary` or `NSArray`.
 *  @param responseBlock A block object to be executed when the request is sent. This block has no return value and takes the response object created by the client.
 *  response serializer. The response object may be `nil` if network (e.g timeout) or parsing error occurred.
 *
 *  @return The `NBMRequest` object that was sent.
 */
- (NBMRequest *)sendRequestWithMethod:(NSString *)method
                           parameters:(id)parameters
                           completion:(void (^)(NBMResponse *response))responseBlock;

/**
 *  Sends a provided request using websocket as transport channel.
 *
 *  @param requestToSend The `NBMRequest` object to send.
 *  @param responseBlock A block object to be executed when the request is sent. This block has no return value and takes the response object created by the client
 *  response serializer. The response object may be `nil` if network (e.g timeout) or parsing error occurred.
 *
 */
- (void)sendRequest:(NBMRequest *)requestToSend completion:(void (^)(NBMResponse *response))responseBlock;


/**
 *  Creates and sends a notification with the specified method and parameters using websocket as transport channel.
 *  @note Notification is a `NBMRequest` object that produces no server response.
 *
 *  @param method     The notification method. Must not be `nil`.
 *  @param parameters The parameters to encode into the notification. Must be either an `NSDictionary` or `NSArray`, may be 'nil'.
 *
 *  @return The `NBMRequest` object that was sent.
 */
- (NBMRequest *)sendNotificationWithMethod:(NSString *)method
                        parameters:(id)parameters;

/**
 *  Sends a provided notification using websocket as transport channel.
 *
 *  @param notification The `NBMRequest` object to send.
 */
- (void)sendNotification:(NBMRequest *)notification;

/**
 *  Allow to cancel a request and don't wait for a response.
 *
 *  @param request The `NBMRequest` object to cancel.
 */
- (void)cancelRequest:(NBMRequest *)request;

/**
 *  Allow to cancel all requests and don't wait for responses.
 */
- (void)cancelAllRequest;


@end
