//
//  NBMResponse.h
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

#import "NBMMessage.h"

@class NBMResponseError;

/**
 *  Represents a JSON-RPC 2.0 response.
 */
@interface NBMResponse : NSObject <NBMMessage>

/**
 *  The result, which can be of any JSON type (`NSNumber`, `NSString`, `NSDictionary`, `NSArray` or `nil`), is returned if the request was successful.
 *  It's `nil` if the request failed.
 */
@property (nonatomic, readonly) id result;
/**
 *  An `NBMResponseError` object that is returned if the request failed. It's `nil` if the request was successful.
 */
@property (nonatomic, readonly) NBMResponseError *error;
/**
 *   The request identifier echoed back to the caller.
 */
@property (nonatomic, readonly) NSNumber *responseId;

/**
 *  Creates a new JSON-RPC 2.0 response to a successful request.
 *
 *  @param result     The result. The value can map to any JSON type. May be `nil`.
 *  @param responseId The request identifier echoed back to the caller.
 *
 *  @return A JSON-RPC-encoded response.
 */
+ (instancetype)responseWithResult:(id)result
                        responseId:(NSNumber *)responseId;

/**
 *  Creates a new JSON-RPC 2.0 response to a failed request.
 *
 *  @param error      The error value indicating the cause of the failure.
 *  @param responseId The request identifier echoed back to the caller. May be `nil` if the request identifier couldn't be determined (e.g. due to a parse error).
 *
 *  @return A JSON-RPC-encoded response.
 */
+ (instancetype)responseWithError:(id)error
                       responseId:(NSNumber *)responseId;

@end

/**
 *   Standard JSON-RPC 2.0 error codes.
 */
typedef NS_ENUM(NSInteger, NBMResponseErrorCode) {
    /**
     *  Invalid method parameter(s).
     */
    NBMResponseErrorInvalidParamCode = -32602,
    /**
     *  The method does not exist / is not available.
     */
    NBMResponseErrorMethodNotFoundCode = -32601,
    /**
     *  The JSON sent is not a valid Request object.
     */
    NBMResponseErrorInvalidRequestCode = -32600,
    /**
     *  Invalid JSON was received by the server.
     *  An error occurred on the server while parsing the JSON text.
     */
    NBMResponseErrorParseErrorCode = -32700,
    /**
     *  Internal JSON-RPC error.
     */
    NBMResponseErrorInternalErrorCode = -32603,
    /**
     *  Reserved for implementation-defined server-errors.
     */
    NBMResponseErrorServerErrorCode = -32000
};

/**
 *  Represents a JSON-RPC 2.0 error that occurred during the processing of a request.
 */
@interface NBMResponseError : NSObject

/**
 *  An `NSInteger` that indicates the error type.
 */
@property (nonatomic) NSInteger code;
/**
 *  An `NSString` providing a short description of the error.
 */
@property (nonatomic, copy) NSString *message;
/**
 *  Additional information, which may be omitted. Its contents is entirely defined by the application.
 */
@property (nonatomic) id data;
/**
 *  A `NSError` object related to the JSON-RPC 2.0 response error.
 */
@property (nonatomic, readonly) NSError *error;

/**
 *  Creates a new JSON-RPC 2.0 error with the specified code, message and data.
 *
 *  @param code    The error code (standard pre-defined or application-specific).
 *  @param message The error message.
 *  @param data    Optional error data, must map to a valid JSON type.
 *
 *  @return A new JSON-RPC 2.0 error.
 */
+ (instancetype)responseErrorWithCode:(NBMResponseErrorCode)code
                              message:(NSString *)message
                                 data:(id)data;

@end