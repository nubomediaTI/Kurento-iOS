//
//  NBMResponse.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMResponse+Private.h"
#import "NBMResponseError.h"
#import "NBMJSONRCPConstants.h"

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

- (NSDictionary *)toDictionary
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

@end
