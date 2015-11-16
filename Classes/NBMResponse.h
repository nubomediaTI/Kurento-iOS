//
//  NBMResponse.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

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
 *  @param error      An `NBMResponseError` instance indicating the cause of the failure.
 *  @param responseId The request identifier echoed back to the caller. May be `nil` if the request identifier couldn't be determined (e.g. due to a parse error).
 *
 *  @return A JSON-RPC-encoded response.
 */
+ (instancetype)responseWithError:(NBMResponseError *)error
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