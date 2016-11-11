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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NBMTransportChannelState) {
    // State when connecting.
    NBMTransportChannelStateOpening,
    // State when connection is established and ready for use.
    NBMTransportChannelStateOpen,
    // State when disconnecting.
    NBMTransportChannelStateClosing,
    // State when disconnected.
    NBMTransportChannelStateClosed
};

@class NBMTransportChannel;
@protocol NBMTransportChannelDelegate <NSObject>

- (void)channel:(NBMTransportChannel *)channel
 didChangeState:(NBMTransportChannelState)channelState;

- (void)channel:(NBMTransportChannel *)channel
didEncounterError:(NSError *)error;

- (void)channel:(NBMTransportChannel *)channel
didReceiveMessage:(NSDictionary *)messageDictionary;

@end

@interface NBMTransportChannel : NSObject

@property (nonatomic, readonly) NBMTransportChannelState channelState;
@property (nonatomic, weak) id<NBMTransportChannelDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval openChannelTimeout;
@property (nonatomic, assign) NSTimeInterval keepAliveInterval;

- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<NBMTransportChannelDelegate>)delegate;

- (void)open;
- (void)close;
- (void)send:(NSString *)message;
- (void)sendMessage:(NSDictionary *)messageDictionary;

@end
