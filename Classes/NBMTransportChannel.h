//
//  NBMTransportChannel.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 09/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

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
