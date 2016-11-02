//
//  NBMTransportChannel.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 09/10/15.
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NBMLog.h"

#import "NBMTransportChannel.h"
#import "NBMJSONRPCUtilities.h"

#import "SRWebSocket.h"

static NSTimeInterval kChannelTimeoutInterval = 20.0;
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
    self = [self init];
    if (self) {
        _url = url;
        _delegate = delegate;
        _openChannelTimeout = kChannelTimeoutInterval;
        _keepAliveInterval = kChannelKeepaliveInterval;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _processingQueue = dispatch_get_main_queue();
        _processingQueue = dispatch_queue_create("eu.nubomedia.websocket.processing", DISPATCH_QUEUE_SERIAL);
        _channelState = NBMTransportChannelStateClosed;
    }
    return self;
}

- (void)dealloc {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    
    //nil delegate to prevent close event be notified
    _delegate = nil;
    [self close];
}

- (void)open
{
    if (!_socket) { // && _channelState != NBMTransportChannelStateOpen
        //To support Sec-WebSocket-Protocol header
        //https://github.com/square/SocketRocket/issues/24
        NSURLRequest *wsRequest = [[NSURLRequest alloc] initWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_openChannelTimeout];
        SRWebSocket *socket = [[SRWebSocket alloc] initWithURLRequest:wsRequest protocols:@[] allowsUntrustedSSLCertificates:YES];
        [socket setDelegateDispatchQueue:self.processingQueue];
        socket.delegate = self;
        self.socket = socket;
        [_socket open];
        
        self.channelState = NBMTransportChannelStateOpening;
        
        //Opening channel timeout
        if (_openChannelTimeout > 0) {
            dispatch_time_t popoTime = dispatch_time(DISPATCH_TIME_NOW, _openChannelTimeout * NSEC_PER_SEC);
            dispatch_after(popoTime, dispatch_get_main_queue(), ^{
                if (self.channelState == NBMTransportChannelStateOpening) {
                    NSError *timeoutError = [NSError errorWithDomain:NSPOSIXErrorDomain code:60 userInfo:@{NSLocalizedDescriptionKey : @"Operation timed out"}];
                    [socket.delegate webSocket:socket didFailWithError:timeoutError];
                }
            });
        }
    }
    
    [self addNotificationObservers];
}

- (void)close
{
    if (_channelState != NBMTransportChannelStateClosed) {
        [_socket close];
        self.channelState = NBMTransportChannelStateClosing;
    }
    else {
        [self cleanupChannel];
    }
}

- (void)send:(NSString *)message {
    if (message) {
        if (_channelState == NBMTransportChannelStateOpen) {
            DDLogVerbose(@"WebSocket: did send message: %@", message);
            [self.socket send:message];
        } else {
            DDLogWarn(@"Socket is not ready to send a message!");
        }
    }
}

- (void)sendMessage:(NSDictionary *)messageDictionary
{
    NSParameterAssert(messageDictionary);
    
    NSString *jsonString = [NSString nbm_stringFromJSONDictionary:messageDictionary];
    [self send:jsonString];
}

#pragma mark - NSObject

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"channelState"]) {
        return NO;
    }
    
    return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark - Private

- (void)setChannelState:(NBMTransportChannelState)channelState {
    if (_channelState != channelState) {
        [self willChangeValueForKey:@"channelState"];
        _channelState = channelState;
        [self didChangeValueForKey:@"channelState"];
        [_delegate channel:self didChangeState:channelState];
    }
}

- (void)scheduleTimer
{
    [self invalidateTimer];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.keepAliveInterval target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.keepAliveTimer = timer;
}

- (void)invalidateTimer
{
    [_keepAliveTimer invalidate];
    _keepAliveTimer = nil;
}

- (void)handleTimer:(NSTimer *)timer
{
    if (_socket) {
        [self sendPing];
        [self scheduleTimer];
    } else {
        [self invalidateTimer];
    }
}

- (void)sendPing
{
    //check for socket status
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil];
    }
}

- (void)cleanupChannel
{
    [self removeNotificationObservers];
    
    _socket.delegate = nil;
    _socket = nil;
    self.channelState = NBMTransportChannelStateClosed;
    
    [self invalidateTimer];
}

- (void)applicationWillEnterForeground
{
    // TODO: Reopen the socket here?
}

- (void)applicationDidEnterBackground
{
    // TODO: Cleanup socket resources here?
}

- (void)addNotificationObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNotificationObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [center removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.channelState = NBMTransportChannelStateOpen;
        //Keep-alive
        [self scheduleTimer];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)messageData
{
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate channel:self didEncounterError:error];
        [self cleanupChannel];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self cleanupChannel];
    });
}

@end
