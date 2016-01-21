//
//  NBMTreeClient.h
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
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

#import <Foundation/Foundation.h>

@class NBMJSONRPCClient;
@class RTCICECandidate;
@class NBMTreeEndpoint;
@protocol NBMTreeClientDelegate;

typedef NS_ENUM(NSInteger, NBMTreeClientErrorCode) {
    NBMTreeClientGenericErrorCode = 0,
    NBMTreeClientTimeoutErrorCode,
    NBMTreeClientTransportErrorCode
};

@interface NBMTreeClient : NSObject

@property (nonatomic, weak, readonly) id<NBMTreeClientDelegate> delegate;
@property (nonatomic, readonly) NSSet *treeEndpoints;
@property (nonatomic, assign, readonly) NSTimeInterval timeout;
@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;
@property (nonatomic, copy, readonly) NSString *treeId;

- (instancetype)initWithURL:(NSURL *)wsURL delegate:(id<NBMTreeClientDelegate>)delegate;

- (void)connect:(NSTimeInterval)timeout;

- (void)createTree:(NSString *)treeId completion:(void (^)(NSError *error))block;
- (void)releaseTree:(NSString *)treeId completion:(void (^)(NSError *error))block;

- (void)setSource:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void (^)(NSString *sdpAnswer, NSError *error))block;
- (void)removeSourceOfTree:(NSString *)treeId completion:(void (^)(NSError *error))block;

- (void)addSink:(NSString *)sdpOffer tree:(NSString *)treeId completion:(void(^)(NBMTreeEndpoint *endpoint, NSError *error))block;
- (void)removeSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void(^)(NSError *error))block;

- (void)addICECandidate:(RTCICECandidate *)candidate forSink:(NSString *)sinkId tree:(NSString *)treeId completion:(void(^)(NSError *error))block;

@end
