//
//  NBMRequest.h
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
