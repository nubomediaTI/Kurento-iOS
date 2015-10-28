//
//  NBMMessage.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 24/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const kNBMJSONRPCVersion;

@interface NBMMessage : NSObject

@property (nonatomic, copy) NSString *sessionId;

+ (NSString *)version;
- (NSDictionary *)toDictionary;
- (NSString *)JSONString;

// Disallow init and don't add to documentation
//- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
