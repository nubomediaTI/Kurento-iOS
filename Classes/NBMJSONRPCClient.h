//
//  NBMJSONRPCClient.h
//  Copyright (c) 2015 Telecom Italia S.p.A. All rights reserved.
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

@class NBMJSONRPCClient, NBMRequest, NBMResponse, NBMResponseError;
/**
 *  NBMJSONRPCClientDelegate is a protocol for an object that must be
 *  implemented to get messages from NBMJSONRPClient.
 */
@protocol NBMJSONRPCClientDelegate <NSObject>

/**
 *  Sent when the client has opened websocket channel and become ready to send requests.
 *
 *  @param client The client sending the message.
 */
- (void)clientDidConnect:(NBMJSONRPCClient *)client;

- (void)clientDidDisconnect:(NBMJSONRPCClient *)client;
/**
 *  Sent when the client has received a request (usually notifications).
 *
 *  @param client  The client sending the message.
 *  @param request The `NBMRequest` received by the client.
 */
- (void)client:(NBMJSONRPCClient *)client didReceiveRequest:(NBMRequest *)request;
/**
 *  Sent when the client did encounter an error that forced websocket channel closing.
 *
 *  @param client The client sending the message.
 *  @param error  The error indicating how the communication failed.
 */
- (void)client:(NBMJSONRPCClient *)client didFailWithError:(NSError *)error;

@end

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

@property (nonatomic, assign) BOOL autoConnect;

+ (instancetype)defaultConfiguration;

@end

/**
 *  NBMJSONRPCClient object communicates with web sockets using the JSON-RPC 2.0 protocol.
 *  @see http://www.jsonrpc.org/specification
 */
@interface NBMJSONRPCClient : NSObject

/**
 *  The URL for the websocket.
 */
@property (nonatomic) NSURL *url;

@property (nonatomic, readonly) NBMJSONRPCClientConfiguration *configuration;

/**
 * The delegate object for the client.
 */
@property (nonatomic, weak) id<NBMJSONRPCClientDelegate>delegate;

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

/**
 *  Creates and initializes a JSON-RPC client with the specified endpoint.
 *
 *  @param url      The endpoint URL.
 *  @param delegate The delegate object for the client.
 *
 *  @return An initialized JSON-RPC client.
 */
- (instancetype)initWithURL:(NSURL *)url delegate:(id<NBMJSONRPCClientDelegate>)delegate;

- (instancetype)initWithURL:(NSURL *)url configuration:(NBMJSONRPCClientConfiguration *)configuration delegate:(id<NBMJSONRPCClientDelegate>)delegate;

/**
 *  Creates and sends a request with the specified method using websocket as transport channel.
 *
 *  @param method        The request method. Musto not be `nil`.
 *  @param responseBlock A block object to be executed when the request is sent. This block has no return value and takes the response object created by the client response serializer.
 *                       The response object may be `nil` if network (e.g timeout) or parsing error occurred.
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
 *  @param responseBlock A block object to be executed when the request is sent. This block has no return value and takes the response object created by the client response serializer.
 *                       The response object may be `nil` if network (e.g timeout) or parsing error occurred.
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
 *  @param responseBlock A block object to be executed when the request is sent. This block has no return value and takes the response object created by the client response serializer.
 *                       The response object may be `nil` if network (e.g timeout) or parsing error occurred.
 */
- (void)sendRequest:(NBMRequest *)requestToSend completion:(void (^)(NBMResponse *response))responseBlock;


/**
 *  Creates and sends a notification with the specified method and parameters using websocket as transport channel.
 *  @note Notification is a `NBMRequest` object that produces no server response.
 *
 *  @param method     The notification method. Must not be `nil`.
 *  @param parameters The parameters to encode into the notification. Must be either an `NSDictionary` or `NSArray`.
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
