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

#import "NBMRoom.h"
#import "NBMPeer.h"

@interface NBMRoom ()

@property (nonatomic, strong) NSSet *mutablePeers;

@end

@implementation NBMRoom

- (instancetype)initWithUsername:(NSString *)username roomName:(NSString *)name roomURL:(NSURL *)url dataChannels:(BOOL)dataChannels {
    NSParameterAssert(username);
    NSParameterAssert(name);
    NSParameterAssert(url);
    
    self = [super init];
    if (self) {
        _mutablePeers = [NSMutableSet set];
        _localPeer = [[NBMPeer alloc] initWithId:username];
        _name = name;
        _url = url;
        _dataChannels = dataChannels;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@: name: %@ peers: %@]", NSStringFromClass([self class]), self.name, [self.mutablePeers allObjects]];
}

- (NSString *)debugDescription {
    return self.description;
}

#pragma mark - Properties

- (NSDictionary *)peers
{
    NSMutableDictionary *mutablePeersCopy = [self.mutablePeers mutableCopy];
    [mutablePeersCopy removeObjectForKey:self.localPeer.identifier];
    
    return [mutablePeersCopy copy];
}

@end
