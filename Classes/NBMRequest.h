//
//  NBMRequest.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

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
