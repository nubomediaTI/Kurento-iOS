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

#import "NBMPeer.h"

@interface NBMPeer ()

@property (nonatomic, strong) NSMutableSet *mutableStreams;

@end

@implementation NBMPeer

- (instancetype)initWithId:(NSString *)peerId {
    self = [super init];
    if (self) {
        _identifier = peerId;
        _mutableStreams = [NSMutableSet set];
    }
    return self;
}

- (void)addStream:(NSString *)streamId {
    if (streamId) {
        [self.mutableStreams addObject:streamId];
    }
}

- (void)removeStream:(NSString *)streamId {
    if (streamId) {
        [self.mutableStreams removeObject:streamId];
    }
}

- (BOOL)hasStream:(NSString *)streamId {
    if (!streamId) {
        return NO;
    }
    return [self.mutableStreams containsObject:streamId];
}

- (NSSet *)streams {
    return [self.mutableStreams copy];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@: id [%@] streams [%@]]", NSStringFromClass([self class]), self.identifier, self.streams];
}

- (NSString *)debugDescription {
    return self.description;
}

- (BOOL)isEqual:(NBMPeer *)object {
    if ([object isKindOfClass:[NBMPeer class]]) {
        return [object.identifier isEqualToString:self.identifier];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

@end
