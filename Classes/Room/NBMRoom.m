//
//  NBMRoom.m
//  Copyright (c) 2016 Telecom Italia S.p.A. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NBMRoom.h"
#import "NBMPeer.h"

@interface NBMRoom ()

@property (nonatomic, strong) NSSet *mutablePeers;

@end

@implementation NBMRoom

- (instancetype)initWithUsername:(NSString *)username roomName:(NSString *)name roomURL:(NSURL *)url {
    NSParameterAssert(username);
    NSParameterAssert(name);
    NSParameterAssert(url);
    
    self = [super init];
    if (self) {
        _mutablePeers = [NSMutableSet set];
        _localPeer = [[NBMPeer alloc] initWithId:username];
        _name = name;
        _url = url;
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
