//
//  NBMResponse.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMMessage.h"

@class NBMResponseError;
@interface NBMResponse : NBMMessage

@property (nonatomic, readonly) id result;
@property (nonatomic, readonly) NBMResponseError *error;
@property (nonatomic, readonly) NSNumber *responseId;

+ (instancetype)responseWithResult:(id)result
                        responseId:(NSNumber *)responseId;

+ (instancetype)responseWithError:(NBMResponseError *)error
                       responseId:(NSNumber *)responseId;

@end
