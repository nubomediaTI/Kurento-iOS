//
//  NBMResponse.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMResponse+Private.h"

#import "NBMJSONRPCConstants.h"
#import "NBMUtilities.h"

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
    responseError.code = code;
    if (!message || message.length == 0) {
        message = JSONRPCLocalizedErrorMessageForCode(code);
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

@implementation NBMResponse

@synthesize responseId, result, error;

#pragma mark - Private

+ (instancetype)responseWithResult:(id)result
                        responseId:(NSNumber *)responseId
{
    NSParameterAssert(result);
    
    if (!responseId) {
        responseId = @(0);
    }
    
    NBMResponse *response = [[NBMResponse alloc] init];
    response.result = result;
    response.responseId = responseId;
    
    return response;
}

+ (instancetype)responseWithError:(NBMResponseError *)error
                       responseId:(NSNumber *)responseId
{
    NSParameterAssert(error);
    
    if (!responseId) {
        responseId = @(0);
    }
    
    NBMResponse *response = [[NBMResponse alloc] init];
    response.error = error;
    response.responseId = responseId;
    
    return response;
}

+ (instancetype)responseWithJSONDictionary:(NSDictionary *)json
{
    id result = json[kResultKey];
    id error = json[kErrorKey];
    NSNumber *ack = json[kIdKey];
    
    NBMResponse *response;
    if (result) {
        response = [NBMResponse responseWithResult:result responseId:ack];
    } else {
        response = [NBMResponse responseWithError:error responseId:ack];
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
    [json setObject:kJsonRpcVersion forKey:kJsonRpcKey];
    if (self.result) {
        [json setObject:self.result forKey:kResultKey];
    } else if (self.error) {
        [json setObject:[self.error errorDictionary] forKey:kErrorKey];
    }
    [json setObject:self.responseId forKey:kIdKey];
    
    return [json copy];
}

- (NSString *)toJSONString {
    return [NSString nbm_stringFromJSONDictionary:[self toJSONDictionary]];
}

@end
