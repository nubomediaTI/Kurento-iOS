//
//  NBMResponse.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMResponse+Private.h"

#import "NBMJSONRPCConstants.h"
#import "NBMJSONRPCUtilities.h"
#import "NBMJSONRPCError.h"

static NSString* JSONRPCLocalizedErrorMessageForCode(NSInteger code) {
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

+ (instancetype)responseErrorWithCode:(NBMResponseErrorCode)code
                              message:(NSString *)message
                                 data:(id)data
{
    NBMResponseError *responseError = [[NBMResponseError alloc] init];
    if (code == 0) {
        code = NBMResponseErrorParseErrorCode;
    }
    responseError.code = code;
    if (!message || message.length == 0) {
        message = JSONRPCLocalizedErrorMessageForCode(code);
    }
    responseError.message = message;
    responseError.data = data;
    
    return responseError;
}

- (NSError *)error {
    return [NBMJSONRPCError errorWithCode:self.code message:self.message userInfo:[self errorDictionary] underlyingError:nil];
}

- (NSDictionary *)errorDictionary
{
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [errorDict setObject:@(self.code) forKey:NBMJSONRPCCodeKey];
    [errorDict setObject:self.message forKey:NBMJSONRPCMessageKey];
    if (self.data) {
        [errorDict setObject:self.data forKey:NBMJSONRPCDataKey];
    }
    return errorDict;
}

@end

@implementation NBMResponse

@synthesize responseId, result, error;

#pragma mark - Private

+ (instancetype)responseWithResult:(id)result
                        responseId:(NSNumber *)responseId
{
    if (!responseId) {
        responseId = @(0);
    }
    
    NBMResponse *response = [[NBMResponse alloc] init];
    response.result = result;
    response.responseId = responseId;
    
    return response;
}

+ (instancetype)responseWithError:(id)error
                       responseId:(NSNumber *)responseId
{
    if (!responseId) {
        responseId = @(0);
    }
    
    NBMResponse *response = [[NBMResponse alloc] init];
    NSDictionary *errorDict = (NSDictionary *)error;
    NSNumber *errorCode = errorDict[NBMJSONRPCCodeKey];
    NSString *errorMessage = errorDict[NBMJSONRPCMessageKey];
    id errorData = errorDict[NBMJSONRPCDataKey];
    NBMResponseError *responseError = [NBMResponseError responseErrorWithCode:errorCode.integerValue message:errorMessage data:errorData];
    response.error = responseError;
    response.responseId = responseId;
    
    return response;
}

+ (instancetype)responseWithJSONDictionary:(NSDictionary *)json
{
    id result = json[NBMJSONRPCResultKey];
    id error = json[NBMJSONRPCErrorKey];
    NSNumber *ack = json[NBMJSONRPCIdKey];
    
    NBMResponse *response;
    if (error) {
        response = [NBMResponse responseWithError:error responseId:ack];
    } else {
        response = [NBMResponse responseWithResult:result responseId:ack];
    }
    
    return response;
}

#pragma mark - NSObject

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"result: %@, error: %@ responseId: %@",
            self.result, self.error, self.responseId];
}

#pragma mark - Message

- (NSDictionary *)toJSONDictionary
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:NBMJSONRPCVersion forKey:NBMJSONRPCKey];
    if (self.result) {
        [json setObject:self.result forKey:NBMJSONRPCResultKey];
    } else if (self.error) {
        [json setObject:[self.error errorDictionary] forKey:NBMJSONRPCErrorKey];
    }
    [json setObject:self.responseId forKey:NBMJSONRPCIdKey];
    
    return [json copy];
}

- (NSString *)toJSONString {
    return [NSString nbm_stringFromJSONDictionary:[self toJSONDictionary]];
}

@end
