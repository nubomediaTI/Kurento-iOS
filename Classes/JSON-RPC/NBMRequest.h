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
#import "NBMMessage.h"

/**
 *  Represents a JSON-RPC 2.0 request.
 */
@interface NBMRequest : NSObject  <NBMMessage>

/**
 *  The request identifier which is echoed back to the client with the response.
 */
@property (nonatomic, readonly) NSNumber *requestId;
/**
 *  The name of the requested method.
 */
@property (nonatomic, copy, readonly) NSString *method;
/**
 *  The parameters encoded into the request, these are an `NSDictionary` or `NSArray.
 */
@property (nonatomic, readonly) id parameters;


/**
 *  Creates and initializes a JSON-RPC 2.0 request with the specified method
 *
 *  @param method The name of the requested method. Must not be `nil`.
 *
 *  @return An initialized JSON-RPC request.
 */
+ (instancetype)requestWithMethod:(NSString *)method;

/**
 *  Creates and initializes a JSON-RPC 2.0 request with the specified method and parameters (named or positional).
 *
 *  @param method     The name of the requested method. Must not be `nil`.
 *  @param parameters The parameters to encode into the request. Must be either an `NSDictionary` or `NSArray`.
 *
 *  @return An initialized JSON-RPC request.
 */
+ (instancetype)requestWithMethod:(NSString *)method
                       parameters:(id)parameters;


@end
