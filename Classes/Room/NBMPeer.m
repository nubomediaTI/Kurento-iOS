//
//  NBMPeer.m
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
    return [NSString stringWithFormat:@"[%@: %@]", NSStringFromClass([self class]), self.identifier];
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
