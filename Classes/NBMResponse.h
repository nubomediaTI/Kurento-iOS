//
//  NBMResponse.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMMessage.h"

@class NBMResponseError;
@interface NBMResponse : NSObject <NBMMessage>

@property (nonatomic, readonly) id result;
@property (nonatomic, readonly) NBMResponseError *error;
@property (nonatomic, readonly) NSNumber *responseId;

+ (instancetype)responseWithResult:(id)result
                        responseId:(NSNumber *)responseId;

+ (instancetype)responseWithError:(NBMResponseError *)error
                       responseId:(NSNumber *)responseId;

@end

typedef NS_ENUM(NSInteger, NBMResponseErrorCode) {
    NBMResponseErrorInvalidParamCode = -32602,
    NBMResponseErrorMethodNotFoundCode = -32601,
    NBMResponseErrorInvalidRequestCode = -32600,
    NBMResponseErrorParseErrorCode = -32700,
    NBMResponseErrorInternalErrorCode = -32603,
    NBMResponseErrorServerErrorCode = -32000
};

@interface NBMResponseError : NSObject

@property (nonatomic) NSInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic) id data;

+ (instancetype)responseErrorWithCode:(NBMResponseErrorCode)code
                              message:(NSString *)message
                                 data:(id)data;

@end