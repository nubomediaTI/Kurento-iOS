//
//  NBMJSONRPCClient.m
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

#import "NBMJSONRPCClient.h"
#import "NBMJSONRPCClientDelegate.h"
#import "NBMJSONRPCClientError.h"

#import "NBMTransportChannel.h"
#import "NBMRequest+Private.h"
#import "NBMResponse+Private.h"

#import "NBMJSONRPCConstants.h"
#import "NBMTimeoutable.h"

#import "NBMLog.h"
#import "NBMJSONRPCUtilities.h"

//NBMRequestPack

typedef void(^NBMResponseBlock)(NBMResponse *response);

@interface NBMRequestPack : NBMTimeoutable

@property (nonatomic) NBMRequest *request;
@property (nonatomic, copy) NBMResponseBlock responseBlock;
@property (nonatomic) NSUInteger retried;

- (instancetype)initWithRequest:(NBMRequest *)request
                  responseBlock:(NBMResponseBlock)responseBlock
                timeoutDelegate:(id<NBMTimeoutableDelegate>)delegate;


@end

@implementation NBMRequestPack

#pragma mark - Public

- (instancetype)initWithRequest:(NBMRequest *)request
                  responseBlock:(NBMResponseBlock)responseBlock
                timeoutDelegate:(id<NBMTimeoutableDelegate>)timeoutDelegate
{
    NSParameterAssert(request);
    if (responseBlock) {
        NSParameterAssert(timeoutDelegate);
    }
    
    self = [super init];
    if (self) {
        _request = request;
        _responseBlock = responseBlock;
        _timeoutDelegate = timeoutDelegate;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return  YES;
    }
    if (![object isKindOfClass:[NBMRequestPack class]]) {
        return NO;
    }
    return [self isEqualToRequestPack:(NBMRequestPack *)object];
}

- (NSUInteger)hash
{
    return [self.request hash];
}

#pragma mark - Private

- (BOOL)isEqualToRequestPack:(NBMRequestPack *)requestPack
{
    if (!requestPack) {
        return NO;
    }
    return [self.request isEqual:requestPack.request];
}

@end

//NBMProcessedResponse

@interface NBMProcessedResponse : NBMTimeoutable

@property (nonatomic) NSNumber *ack;

- (instancetype)initWithAck:(NSNumber *)ack timeoutDelegate:(id<NBMTimeoutableDelegate>)timeoutDelegate;

- (NSNumber *)ack;

@end

@implementation NBMProcessedResponse

- (instancetype)initWithAck:(NSNumber *)ack
            timeoutDelegate:(id<NBMTimeoutableDelegate>)timeoutDelegate
{
    NSParameterAssert(ack);
    
    self = [super init];
    if (self) {
        _ack = ack;
        //maybe weak if timeout delegate is assigned while it's being deallocated?
        _timeoutDelegate= timeoutDelegate;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return  YES;
    }
    if (![object isKindOfClass:[NBMProcessedResponse class]]) {
        return NO;
    }
    return [self isEqualToProcessedResponse:(NBMProcessedResponse *)object];
}

- (NSUInteger)hash
{
    return [self.ack hash];
}

#pragma mark - Private

- (BOOL)isEqualToProcessedResponse:(NBMProcessedResponse *)processedResponse
{
    if (!processedResponse) {
        return NO;
    }
    return [self.ack isEqualToNumber:processedResponse.ack];
}

@end

// NBMJSONRPCClientConfiguration

static NSTimeInterval kRequestTimeoutInterval = 5;
static NSTimeInterval kRequestMaxRetries = 3;

@interface NBMJSONRPCClientConfiguration ()

@property (nonatomic) NSTimeInterval responseTimeout;
@property (nonatomic) NSTimeInterval duplicatesResponseTimeout;

@end

@implementation NBMJSONRPCClientConfiguration

+ (instancetype)defaultConfiguration {
    NBMJSONRPCClientConfiguration *config = [[NBMJSONRPCClientConfiguration alloc] init];
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestTimeout = kRequestTimeoutInterval;
        _requestMaxRetries = kRequestMaxRetries;
        _autoConnect = YES;
    }
    return self;
}

- (void)setRequestTimeout:(NSTimeInterval)requestTimeout {
    if (requestTimeout > 0) {
        _requestTimeout = requestTimeout;
    }
}

@end

@interface NBMJSONRPCClient () <NBMTimeoutableDelegate, NBMTransportChannelDelegate>

@property (nonatomic) NSUInteger requestId;
@property (nonatomic) NBMTransportChannel *transport;

@property (nonatomic) NSMutableOrderedSet *requestsSent;
@property (nonatomic) NSMutableOrderedSet *responsesSent;
@property (nonatomic) NSMutableOrderedSet *responsesReceived;

@end

@implementation NBMJSONRPCClient

#pragma mark - Public

- (instancetype)initWithURL:(NSURL *)url delegate:(id<NBMJSONRPCClientDelegate>)delegate;
{
    NBMJSONRPCClientConfiguration *defaultConfig = [NBMJSONRPCClientConfiguration defaultConfiguration];
    return [self initWithURL:url configuration:defaultConfig delegate:delegate];
}

- (instancetype)initWithURL:(NSURL *)url configuration:(NBMJSONRPCClientConfiguration *)configuration delegate:(id<NBMJSONRPCClientDelegate>)delegate {
    self = [super init];
    if (self) {
        _url = url;
        if (!configuration) {
            configuration = [NBMJSONRPCClientConfiguration defaultConfiguration];
        }
        _configuration = configuration;
        _delegate = delegate;
        
        //Setup message logic
        _requestId = 0;
        _requestsSent = [NSMutableOrderedSet orderedSet]; //Requests cache (sent)
        _responsesSent = [NSMutableOrderedSet orderedSet]; //Response cache (sent)
        _responsesReceived = [NSMutableOrderedSet orderedSet]; //Response cache (received)
        
        _connected = NO;
        if (_configuration.autoConnect) {
            [self connect];
        }
    }
    
    return self;
}

- (void)connect {
    //Setup transport
    if (!_transport) {
        _transport = [[NBMTransportChannel alloc] initWithURL:_url delegate:self];
    }
    
    [_transport open];
}

- (NBMRequest *)sendRequestWithMethod:(NSString *)method completion:(void (^)(NBMResponse *))responseBlock {
    return [self sendRequestWithMethod:method parameters:nil completion:responseBlock];
}

- (NBMRequest *)sendRequestWithMethod:(NSString *)method parameters:(id)parameters completion:(void (^)(NBMResponse *))responseBlock
{
    NBMRequest *request = [NBMRequest requestWithMethod:method parameters:parameters];
    [self sendRequest:request completion:responseBlock];
    
    return request;
}

- (void)sendRequest:(NBMRequest *)requestToSend completion:(void (^)(NBMResponse *))responseBlock {
    //Request
    if (responseBlock) {
        NSUInteger reqId = _requestId++;
        requestToSend.requestId = @(reqId);
        NBMRequestPack *requestPack = [[NBMRequestPack alloc] initWithRequest:requestToSend responseBlock:responseBlock timeoutDelegate:self];
        [self sendRequestPack:requestPack retried:NO];
    }
    else {
        //Notification
        [self sendRequest:requestToSend];
    }
}

- (NBMRequest *)sendNotificationWithMethod:(NSString *)method parameters:(id)parameters {
    return [self sendRequestWithMethod:method parameters:parameters completion:nil];
}

- (void)sendNotification:(NBMRequest *)notification {
    return [self sendRequest:notification];
}

- (void)cancelRequest:(NBMRequest *)request
{
    __block NBMRequestPack *requestPackToCancel;
    [_requestsSent.set enumerateObjectsUsingBlock:^(NBMRequestPack* requestPack, BOOL* stop) {
        if ([requestPack.request isEqual:request]) {
            requestPackToCancel = requestPack;
            *stop = YES;
        }
    }];
    if (requestPackToCancel) {
        [self cancelRequestPack:requestPackToCancel];
    }
}

- (void)cancelAllRequest
{
    NSSet *requestPacks = [_requestsSent copy];
    for (NBMRequestPack *requestPack in requestPacks) {
        [self cancelRequestPack:requestPack];
    }
}

- (NBMJSONRPCConnectionState)connectionState {
    return (NBMJSONRPCConnectionState)self.transport.channelState;
}

- (void)dealloc
{
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    
    //secure transport closing, is needed?
    [_transport close];
    _transport = nil;
//    [self cancelAllRequest];
    //same as
    _requestsSent = nil;
}

#pragma mark - Private

//unused
- (void)setupTransport
{
    _transport = [[NBMTransportChannel alloc] initWithURL:_url delegate:self];
    [_transport open];
}

//unused
- (void)setupMessageLogic
{
    //Requests cache (sent)
    _requestsSent = [NSMutableOrderedSet orderedSet];
    //Response cache (sent)
    _responsesSent = [NSMutableOrderedSet orderedSet];
    //Response cache (received)
    _responsesReceived = [NSMutableOrderedSet orderedSet];
    
    //Requests
    _requestId = 0;
//    _requestTimeout = self.configuration.requestTimeout;
//    _requestMaxRetries = self.configuration.requestMaxRetries;
    
    //Responses
//    _responseTimeout = _requestTimeout;
//    _duplicatesResponseTimeout = _responseTimeout;
}

- (void)decodeMessage:(NSDictionary *)messageDictionary
{
    messageDictionary = [self validateMessage:messageDictionary];
    //Message validation
    if (!messageDictionary) {
        return;
    }
    
    NSString *method = messageDictionary[NBMJSONRPCMethodKey];
    NSNumber *ack = messageDictionary[NBMJSONRPCIdKey];
    NBMRequestPack *requestPack = [self getRequestPackById:ack];
    
    //Request or Response with own method
    if (method) {
        //Response WITH method to process
        if (requestPack) {
            NBMResponse *response = [NBMResponse responseWithJSONDictionary:messageDictionary];
            [self processResponse:response requestPack:requestPack error:nil];
            return;
            
            //Manage method as errors?
            
            //TODO: processRequest to reply?
        }
        //Response WITH method already processed?
        if ([self checkAndManageDuplicatedResponse:messageDictionary]) {
            return;
        }
        
        //Request to process
        NBMRequest *request = [NBMRequest requestWithJSONDicitonary:messageDictionary];
        [self processRequest:request];
        return;
    }
    
    //Response WITHOUT method already processed?
    if (!requestPack) {
        if (![self checkAndManageDuplicatedResponse:messageDictionary]) {
            DDLogWarn(@"No callback was defined for this message: %@", [NSString nbm_stringFromJSONDictionary:messageDictionary]);
            return;
        }
    }
    //Response WITHOUT method to process
    NBMResponse *response = [NBMResponse responseWithJSONDictionary:messageDictionary];
    [self processResponse:response requestPack:requestPack error:nil];
}

- (NSDictionary *)validateMessage:(NSDictionary *)messageDictionary
{
    NSString *version = messageDictionary[NBMJSONRPCKey];
    if (![version isEqualToString:NBMJSONRPCVersion]) {
        DDLogWarn(@"Invalid JSON-RPC version: %@", version);
        return nil;
    }
    
    //Response
    NSString *method = messageDictionary[NBMJSONRPCMethodKey];
    if (!method) {
        NSNumber *responseId = messageDictionary[NBMJSONRPCIdKey];
        if (!responseId) {
            DDLogWarn(@"No response id (ack) is defined: %@", messageDictionary);
            return nil;
        }
        id result = messageDictionary[NBMJSONRPCResultKey];
        id error = messageDictionary[NBMJSONRPCErrorKey];
        if (result && error) {
            DDLogWarn(@"Both result and error are defined: %@", messageDictionary);
            return nil;
        }
        if (!result && !error) {
            DDLogWarn(@"No result or error is defined: %@", messageDictionary);
            return nil;
        }
    }
    //...otherwise is a Request/Notification
    
    return messageDictionary;
}

- (BOOL)checkAndManageDuplicatedResponse:(NSDictionary *)responseDicitonary
{
    NSNumber *ack = responseDicitonary[NBMJSONRPCIdKey];
    NBMProcessedResponse *processedResponse = [self getProcessedResponseByAck:ack remove:NO];
    if (!processedResponse) {
        return NO;
    }
    
    DDLogWarn(@"Response already processed: %@", [NSString nbm_stringFromJSONDictionary:responseDicitonary]);
    //Update duplicated responses timeout
    [self storeProcessedResponse:processedResponse];
    return YES;
}

#pragma mark Request

- (void)sendRequestPack:(NBMRequestPack *)requestPack retried:(BOOL)retried
{
    NBMRequest *request = requestPack.request;
    if (retried) {
        DDLogWarn(@"#%lu retry for Request: %@", (unsigned long)requestPack.retried, request);
        //Remove a processed Response if present (and clear timeout)
        NBMProcessedResponse *processedResponse = [self getProcessedResponseByAck:request.requestId remove:YES];
        //Clear timeout already present in NBMProcessedResponse dealloc
        [processedResponse clearTimeout];
    }
    
    //Set Request timeout
    NSTimeInterval timeout = _configuration.requestTimeout * pow(2, requestPack.retried);
    requestPack.timeout = timeout;
    requestPack.retried += 1;
    [_requestsSent addObject:requestPack];
    
    [self sendRequest:request];
}

- (void)sendRequest:(NBMRequest *)request
{
    NSString *requestString = [request toJSONString];
    [_transport send:requestString];
}

- (void)cancelRequestPack:(NBMRequestPack *)requestPack
{
    //nil copied block (check if is needed)
    requestPack.responseBlock = nil;
    [requestPack clearTimeout];
    [_requestsSent removeObject:requestPack];
    
    // Start duplicated responses timeout
    NBMProcessedResponse *processedResponse = [[NBMProcessedResponse alloc] initWithAck:requestPack.request.requestId timeoutDelegate:self];
    if (processedResponse) {
        [self storeProcessedResponse:processedResponse];
    }
}

- (NBMRequestPack *)getRequestPackById:(NSNumber *)requestId
{
    __block NBMRequestPack *requestPack;
    if (!requestId) {
        return nil;
    }
    [_requestsSent.set enumerateObjectsUsingBlock:^(NBMRequestPack* aRequestPack, BOOL *stop) {
        if ([aRequestPack.request.requestId isEqualToNumber:requestId]) {
            requestPack = aRequestPack;
            *stop = YES;
        }
    }];
    
    return requestPack;
}

- (void)processRequest:(NBMRequest *)request {
    if ([self.delegate respondsToSelector:@selector(client:didReceiveRequest:)]) {
        [self.delegate client:self didReceiveRequest:request];
    }
}

#pragma mark Response

- (NBMProcessedResponse *)getProcessedResponseByAck:(NSNumber *)ack remove:(BOOL)remove
{
    __block NBMProcessedResponse *processedResponse;
    if (!ack) {
        return nil;
    }
    [_responsesReceived.set enumerateObjectsUsingBlock:^(NBMProcessedResponse *aProcessedResponse, BOOL *stop) {
        if ([aProcessedResponse.ack isEqualToNumber:ack]) {
            processedResponse = aProcessedResponse;
            *stop = YES;
        }
    }];
    
    if (processedResponse && remove) {
        [_responsesReceived removeObject:processedResponse];
    }
    
    return processedResponse;
}

- (void)processResponse:(NBMResponse *)response requestPack:(NBMRequestPack *)requestPack {
    [self processResponse:response requestPack:requestPack error:nil];
}

- (void)processResponse:(NBMResponse *)response requestPack:(NBMRequestPack *)requestPack error:(NSError *)error {
    if (requestPack) {
        requestPack.responseBlock(response);
        [self cancelRequestPack:requestPack];
    }
}

/**
 * Store the response to ignore duplicated messages later
 */
- (void)storeProcessedResponse:(NBMProcessedResponse *)processedResponse
{
    [processedResponse setTimeout:_configuration.duplicatesResponseTimeout];
    [_responsesReceived addObject:processedResponse];
}

#pragma mark TransportChannel delegate

- (void)channel:(NBMTransportChannel *)channel didChangeState:(NBMTransportChannelState)channelState
{
    switch (channelState) {
        case NBMTransportChannelStateClosing:
            break;
        case NBMTransportChannelStateClosed: {
            _connected = NO;
            if ([self.delegate respondsToSelector:@selector(clientDidDisconnect:)]) {
                [self.delegate clientDidDisconnect:self];
            }
            break;
        }
        case NBMTransportChannelStateOpening:
            break;
        case NBMTransportChannelStateOpen: {
            _connected = YES;
            if ([self.delegate respondsToSelector:@selector(clientDidConnect:)]) {
                [self.delegate clientDidConnect:self];
            }
            break;
        }
    }
}

- (void)channel:(NBMTransportChannel *)channel didReceiveMessage:(NSDictionary *)messageDictionary
{
    [self decodeMessage:messageDictionary];
}

- (void)channel:(NBMTransportChannel *)channel didEncounterError:(NSError *)error {
    //Open channel timeout error
    if ([error.domain isEqualToString:NSPOSIXErrorDomain] && error.code == 60) {
        NSString *msg = @"Failed to initialize transport channel, operation goes timeout";
        NSError *timeoutError = [NBMJSONRPCClientError errorWithCode:NBMJSONRPCClientInitializationErrorCode message:msg underlyingError:error];
        error = timeoutError;
    } 
//    if ([self.delegate respondsToSelector:@selector(client:didFailWithError:)]) {
//        [self.delegate client:self didFailWithError:error];
//    }
}

#pragma mark TimeoutableDelegate

- (void)timeoutFired:(id)timeoutable
{
    __weak typeof(self) weakSelf = self;
    
    //Timeout fired on RequestPack
    if ([timeoutable isKindOfClass:[NBMRequestPack class]]) {
        NBMRequestPack *requestPack = (NBMRequestPack *)timeoutable;
        if (requestPack.retried < _configuration.requestMaxRetries) {
            [weakSelf sendRequestPack:requestPack retried:YES];
            return;
        }
    
        DDLogWarn(@"Request %@ has timed out!", requestPack.request);
        [weakSelf processResponse:nil requestPack:requestPack];
    }
    //Timeout fired on processed Response
    else if ([timeoutable isKindOfClass:[NBMProcessedResponse class]]) {
        NBMProcessedResponse *processedResponse = (NBMProcessedResponse *)timeoutable;
        //clear timeout is done in dealloc
        DDLogWarn(@"Processed response removed from cache - ack:%@", processedResponse.ack);
        [_responsesReceived removeObject:processedResponse];
    }
}

@end
