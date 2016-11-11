// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
#import "NBMRequest+Private.h"

#import "NBMJSONRPCConstants.h"
#import "NBMJSONRPCUtilities.h"

@implementation NBMRequest

@synthesize requestId, method, parameters;

#pragma mark - Public

+ (instancetype)requestWithMethod:(NSString *)method {
    return [NBMRequest requestWithMethod:method parameters:nil];
}

+ (instancetype)requestWithMethod:(NSString *)method
                       parameters:(id)parameters
{
    return [NBMRequest requestWithMethod:method parameters:parameters requestId:nil];
}

#pragma mark - Private

+ (instancetype)requestWithMethod:(NSString *)method
                       parameters:(id)parameters
                        requestId:(NSNumber *)requestId
{
    NSParameterAssert(method);
    if (parameters) {
        NSAssert([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]], @"Expect NSArray or NSDictionary in JSON-RPC parameters");
    }
    
    NBMRequest *request = [[NBMRequest alloc] init];
    request.method = method;
    request.parameters = parameters;
    request.requestId = requestId;
    
    return request;
}

+ (instancetype)requestWithJSONDicitonary:(NSDictionary *)json
{
    NSString *method = json[NBMJSONRPCMethodKey];
    id params = json[NBMJSONRPCParamsKey];
    NSNumber *requestId = json[NBMJSONRPCIdKey];
    
    return [NBMRequest requestWithMethod:method parameters:params requestId:requestId];
}

- (BOOL)isEqualToRequest:(NBMRequest *)request
{
    if (!request) {
        return NO;
    }
    
    BOOL hasEqualMethods = (!self.method && !request.method) || ([self.method isEqualToString:request.method]);
    BOOL hasEqualParams = (!self.parameters && !request.parameters) || ([self.parameters isEqualToDictionary:request.parameters]);
    BOOL hasEqualRequestIds = (!self.requestId && !request.requestId) || ([self.requestId isEqualToNumber:request.requestId]);
    
    return hasEqualMethods && hasEqualParams && hasEqualRequestIds;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return  YES;
    }
    if (![object isKindOfClass:[NBMRequest class]]) {
        return NO;
    }
    
    return [self isEqualToRequest:(NBMRequest *)object];
}

- (NSUInteger)hash
{
    return [self.method hash] ^ [self.parameters hash] ^ [self.requestId hash];
}

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"[method: %@, params: %@ id: %@]",
            self.method, self.parameters, self.requestId];
}

#pragma mark - Message

- (NSDictionary *)toJSONDictionary
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:NBMJSONRPCVersion forKey:NBMJSONRPCKey];
    [json setObject:self.method forKey:NBMJSONRPCMethodKey];
    if (self.parameters) {
        [json setObject:self.parameters forKey:NBMJSONRPCParamsKey];
    }
    if (self.requestId) {
        [json setObject:self.requestId forKey:NBMJSONRPCIdKey];
    }
    
    return [json copy];
}

- (NSString *)toJSONString {
    return [NSString nbm_stringFromJSONDictionary:[self toJSONDictionary]];
}

@end
