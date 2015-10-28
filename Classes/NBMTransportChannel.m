//
//  NBMTransportChannel.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 09/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMTransportChannel.h"
#import "NBMUtilities.h"

#import "RTCSessionDescription.h"
#import "SRWebSocket.h"

static NSTimeInterval kChannelKeepaliveInterval = 20.0;

@interface NBMTransportChannel()<SRWebSocketDelegate>

@property (nonatomic, readwrite) NBMTransportChannelState channelState;
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSTimer *keepAliveTimer;
@property (nonatomic, strong) dispatch_queue_t processingQueue;
@property (nonatomic, strong) NSURL* url;

@end

@implementation NBMTransportChannel

#pragma mark -
#pragma mark Public

- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<NBMTransportChannelDelegate>)delegate {
    self = [super init];
    if (self) {
        _url = url;
        _delegate = delegate;
        _processingQueue = dispatch_get_main_queue();
        _channelState = NBMTransportChannelStateClosed;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _processingQueue = dispatch_get_main_queue();
        _channelState = NBMTransportChannelStateClosed;
    }
    return self;
}

- (void)dealloc {
    [self cleanupChannel];
}

- (void)open
{
    if (!_socket) { // && _channelState != NBMTransportChannelStateOpen
        SRWebSocket *socket = [[SRWebSocket alloc] initWithURL:_url];
        [socket setDelegateDispatchQueue:self.processingQueue];
        socket.delegate = self;
        _socket = socket;
        [_socket open];
    }
}

- (void)close
{
    if (_channelState == NBMTransportChannelStateOpen) {
        [_socket close];
    }
}

- (void)sendMessage:(NSDictionary *)messageDictionary
{
    NSParameterAssert(messageDictionary);
    
    NSString *jsonString = [NSString nbm_stringFromJSONDictionary:messageDictionary];
    if (jsonString) {
        if (self.channelState == NBMTransportChannelStateOpen) {
            [self.socket send:jsonString];
        } else {
            DDLogWarn(@"Socket is not ready to send a message!");
        }
    }
}

#pragma mark - Private

- (void)setState:(NBMTransportChannelState)state {
    if (_channelState != state) {
        [self willChangeValueForKey:@"channelState"];
        _channelState = state;
        [self didChangeValueForKey:@"channelState"];
        [_delegate channel:self didChangeState:state];
    }
}

- (void)scheduleTimer
{
    [self invalidateTimer];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:kChannelKeepaliveInterval target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.keepAliveTimer = timer;
}

- (void)invalidateTimer
{
    [self.keepAliveTimer invalidate];
    self.keepAliveTimer = nil;
}

- (void)handleTimer:(NSTimer *)timer
{
    if (self.channelState == NBMTransportChannelStateOpen) {
        [self sendPing];
        [self scheduleTimer];
    }
}

- (void)sendPing
{
    [self.socket sendPing:nil];
}

- (void)cleanupChannel
{
    self.socket.delegate = nil;
    self.socket = nil;
    
    [self invalidateTimer];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    self.channelState = NBMTransportChannelStateOpen;
    //Keep-alive
    [self scheduleTimer];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)messageData
{
    NSDictionary *messageDictionary;
    if ([messageData isKindOfClass:[NSData class]]) {
        messageDictionary = [NSDictionary nbm_dictionaryWithJSONData:messageData];
    } else if ([messageData isKindOfClass:[NSString class]]) {
        messageDictionary = [NSDictionary nbm_dictionaryWithJSONString:messageData];
    } else {
        DDLogWarn(@"Unknown message format: %@", messageData);
    }
    
    DDLogVerbose(@"WebSocket: did receive message: %@", messageDictionary);
    [self.delegate channel:self didReceiveMessage:messageDictionary];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self cleanupChannel];
    self.channelState = NBMTransportChannelStateError;
    //Need error in delegate?
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [self cleanupChannel];
    self.channelState = NBMTransportChannelStateClosed;
}

@end
