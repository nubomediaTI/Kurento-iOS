//
//  NBMTransportChannel.h
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

typedef NS_ENUM(NSInteger, NBMTransportChannelState) {
    // State when disconnected.
    NBMTransportChannelStateClosed,
    // State when connection is established and ready for use.
    NBMTransportChannelStateOpen,
    // State when connection encounters a fatal error.
    NBMTransportChannelStateError
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

- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<NBMTransportChannelDelegate>)delegate;

- (void)open;
- (void)close;
- (void)send:(NSString *)message;
- (void)sendMessage:(NSDictionary *)messageDictionary;

@end
