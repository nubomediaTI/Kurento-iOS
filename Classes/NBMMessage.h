//
//  NBMMessage.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 24/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The base protocol for JSON-RPC 2.0 requests, notifications and responses.
 *  Provides common method for serialisation (to JSON string / to JSON dictionary) of these three message types.
 */
@protocol NBMMessage <NSObject>

/**
 *  Returns a JSON string representation of this JSON-RPC 2.0 message.
 *
 *  @return The `NSString` representing this JSON-RPC 2.0 message.
 */
- (NSString *)toJSONString;

@optional
/**
 *  Returns a JSON dicitonary representation of this JSON-RPC 2.0 message.
 *
 *  @return The `NSDictionary` representing this JSON-RPC 2.0 message.
 */
- (NSDictionary *)toJSONDictionary;

@end

