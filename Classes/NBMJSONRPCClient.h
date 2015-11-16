//
//  NBMJSONRPCClient.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 10/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

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
- (void)clientDidBecomeReady:(NBMJSONRPCClient *)client;
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

/**
 *  NBMJSONRPCClient object communicates with web sockets using the JSON-RPC 2.0 protocol.
 *  @see http://www.jsonrpc.org/specification
 */
@interface NBMJSONRPCClient : NSObject

/**
 *  The URL for the websocket.
 */
@property (nonatomic) NSURL *url;
/**
 *  The timoeut interval for the new request, in seconds. 
 *  Default value is 5.
 */
@property (nonatomic) NSTimeInterval requestTimeout;
/**
 *  The retry number for requests gone in timeout (with no response back). 
 *  Default value is 1.
 */
@property (nonatomic) NSUInteger requestMaxRetries;
/**
 * The delegate object for the client.
 */
@property (nonatomic, weak) id<NBMJSONRPCClientDelegate>delegate;

/**
 *  Creates and initializes a JSON-RPC client with the specified endpoint.
 *
 *  @param url      The endpoint URL.
 *  @param delegate The delegate object for the client.
 *
 *  @return An initialized JSON-RPC client.
 */
- (instancetype)initWithURL:(NSURL *)url delegate:(id<NBMJSONRPCClientDelegate>)delegate;

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
