//
//  NBMRoomClient.h
//  Copyright (c) 2015 Telecom Italia S.p.A. All rights reserved.
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

@class NBMRoom;
@class NBMPeer;
@class RTCICECandidate;
@protocol NBMRoomClientDelegate;

@interface NBMRoomClient : NSObject

@property (nonatomic, weak) id<NBMRoomClientDelegate> delegate;
@property (nonatomic, readonly) NSDictionary *peers;
@property (nonatomic, assign, readonly) NSTimeInterval timeout;
@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;
@property (nonatomic, assign, readonly, getter = isJoined) BOOL joined;

- (NBMPeer *)peerWithIdentifier:(NSString *)identifier;

- (instancetype)initWithRoom:(NBMRoom *)room delegate:(id<NBMRoomClientDelegate>)delegate;
- (instancetype)initWithRoom:(NBMRoom *)room timeout:(NSTimeInterval)timeout delegate:(id<NBMRoomClientDelegate>)delegate;

- (void)joinRoom;
- (void)joinRoom:(void (^)(NSDictionary *peers, NSError *error))block;

- (void)leaveRoom;
- (void)leaveRoom:(void (^)(NSError *error))block;

- (void)publishVideo:(NSString *)sdpOffer loopback:(BOOL)doLoopback;
- (void)publishVideo:(NSString *)sdpOffer loopback:(BOOL)doLoopback completion:(void (^)(NSString *sdpAnswer, NSError *error))block;

- (void)unpublishVideo;
- (void)unpublishVideo:(void (^)(NSError *error))block;

- (void)receiveVideoFromPeer:(NBMPeer *)peer offer:(NSString *)sdpOffer;
- (void)receiveVideoFromPeer:(NBMPeer *)peer offer:(NSString *)sdpOffer completion:(void (^)(NSString *sdpAnswer, NSError *error))block;

- (void)unsubscribeVideoFromPeer:(NBMPeer *)peer;
- (void)unsubscribeVideoFromPeer:(NBMPeer *)peer completion:(void (^)(NSString *sdpAnswer, NSError *error))block;

- (void)sendICECandidate:(RTCICECandidate *)candidate;
- (void)sendICECandidate:(RTCICECandidate *)candidate completion:(void (^)(NSError *error))block;

- (void)sendMessage:(NSString *)message;
- (void)sendMessage:(NSString *)message completion:(void (^)(NSError *error))block;

- (void)sendCustomRequest:(NSDictionary<NSString *, NSString *>*)params;
- (void)sendCustomRequest:(NSDictionary <NSString *, NSString *>*)params completion:(void (^)(NSError *error))block;

@end
