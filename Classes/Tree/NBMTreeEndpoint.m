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

#import "NBMTreeEndpoint.h"

@implementation NBMTreeEndpoint

- (instancetype)initWithIdentifier:(NSString *)identifier sdpAnswer:(NSString *)sdpAnswer {
    NSParameterAssert(identifier);
    self = [super init];
    if (self) {
        _identifier = identifier;
        _sdpAnswer = sdpAnswer;
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@: %@]", NSStringFromClass([self class]), self.identifier];
}

- (NSString *)debugDescription {
    return self.description;
}

- (BOOL)isEqual:(NBMTreeEndpoint *)object {
    if ([object isKindOfClass:[NBMTreeEndpoint class]]) {
        return [object.identifier isEqualToString:self.identifier];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

@end
