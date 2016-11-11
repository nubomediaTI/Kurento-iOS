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

@class NBMJSONRPCClient, NBMRequest;

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

/**
 *  Sent when the client has closed websocket channel.
 *
 *  @param client The client sending the message.
 */
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
