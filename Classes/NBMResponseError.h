//
//  NBMResponseError.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

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

+ (instancetype)responseErrorWithCode:(NSInteger)code
                              message:(NSString *)message
                                 data:(id)data;
- (NSDictionary *)errorDictionary;

@end
