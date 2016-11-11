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

#import "NBMError.h"

static NSString* const NBMErrorDomain = @"eu.nubomediaTI.KurentoToolbox";

@implementation NBMError

+ (NSString *)errorDomain {
    return NBMErrorDomain;
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message {
    return [self errorWithCode:code message:message underlyingError:nil];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message underlyingError:(NSError *)underlyingError {
    return [self errorWithCode:code message:message userInfo:nil underlyingError:underlyingError];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message userInfo:(NSDictionary *)userInfo underlyingError:(NSError *)underlyingError {
    NSMutableDictionary *fullUserInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    [NBMError dictionary:fullUserInfo setObject:message forKey:NSLocalizedDescriptionKey];
    [NBMError dictionary:fullUserInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    userInfo = ([fullUserInfo count] > 0 ? [fullUserInfo copy] : nil);
    
    NSError *error = [NSError errorWithDomain:[self errorDomain] code:code userInfo:userInfo];
    
    return error;
}

#pragma mark - Utility

+ (void)dictionary:(NSMutableDictionary *)dictionary setObject:(id)object forKey:(id<NSCopying>)key {
    if (object && key) {
        [dictionary setObject:object forKey:key];
    }
}

@end
