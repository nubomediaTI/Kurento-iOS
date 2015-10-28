//
//  NBMJSONRPCClient.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 10/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NBMJSONRPCClient, NBMRequest, NBMResponse, NBMResponseError;
@protocol NBMJSONRPCClientDelegate <NSObject>

- (void)client:(NBMJSONRPCClient *)client didReceiveRequest:(NBMRequest *)request;

@end

@interface NBMJSONRPCClient : NSObject

@property (nonatomic) NSURL *url;
@property (nonatomic) NSTimeInterval requestTimeout;
@property (nonatomic) NSUInteger requestMaxRetries;
@property (nonatomic) NSTimeInterval responseTimeout;
@property (nonatomic, weak) id<NBMJSONRPCClientDelegate>delegate;

- (instancetype)initWithURL:(NSURL *)url;

//Request
- (NBMRequest *)sendRequestWithMethod:(NSString *)method
                           parameters:(id)parameters
                           completion:(void (^)(NBMResponse *response))responseBlock;

- (void)sendRequest:(NBMRequest *)requestToSend completion:(void (^)(NBMResponse *response))responseBlock;

//Notification
//Same as the frist method without completion block
- (NBMRequest *)sendNotificationWithMethod:(NSString *)method
                        parameters:(id)parameters;

- (void)sendNotification:(NBMRequest *)notification;

- (void)cancelRequest:(NBMRequest *)request;

- (void)cancelAllRequest;

//Response (not implemented yet)
- (void)sendResponse:(NBMResponse *)response;

@end
