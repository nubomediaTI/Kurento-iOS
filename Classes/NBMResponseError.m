//
//  NBMResponseError.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMResponseError.h"
#import "NBMJSONRCPConstants.h"

//static NSString* const kCodeKey  = @"code";
//static NSString* const kMessageKey  = @"message";
//static NSString* const kDataKey  = @"data";

static NSString* nbm_JSONRPCLocalizedErrorMessageForCode(NSInteger code) {
    switch(code) {
        case NBMResponseErrorParseErrorCode:
            return @"Parse Error";
        case NBMResponseErrorInvalidRequestCode:
            return @"Invalid Request";
        case NBMResponseErrorMethodNotFoundCode:
            return @"Method Not Found";
        case NBMResponseErrorInvalidParamCode:
            return @"Invalid Params";
        case NBMResponseErrorInternalErrorCode:
            return @"Internal Error";
        default:
            return @"Server Error";
    }
}

@implementation NBMResponseError

+ (instancetype)responseErrorWithCode:(NSInteger)code
                              message:(NSString *)message
                                 data:(id)data
{
    NBMResponseError *responseError = [[NBMResponseError alloc] init];
    responseError.code = code;
    if (!message || message.length == 0) {
        message = nbm_JSONRPCLocalizedErrorMessageForCode(code);
    }
    responseError.message = message;
    responseError.data = data;
    
    return responseError;
}

- (NSDictionary *)errorDictionary
{
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [errorDict setObject:@(self.code) forKey:kCodeKey];
    [errorDict setObject:self.message forKey:kMessageKey];
    if (self.data) {
        [errorDict setObject:self.data forKey:kDataKey];
    }
    return errorDict;
}

@end
