//
//  NBMJSONRPCClient.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 10/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMJSONRPCClient.h"

#import "NBMTransportChannel.h"
#import "NBMRequest+Private.h"
#import "NBMResponse+Private.h"
#import "NBMUtilities.h"
#import "NBMJSONRPCConstants.h"
#import "NBMTimeoutable.h"

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

//@property (nonatomic) NSDictionary *responseDictionary;
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

@interface NBMJSONRPCClient () <NBMTimeoutableDelegate, NBMTransportChannelDelegate>

@property (nonatomic) NSUInteger requestId;
@property (nonatomic) NBMTransportChannel *transport;

@property (nonatomic) NSMutableSet *requestsSent;
@property (nonatomic) NSMutableSet *responsesSent;
@property (nonatomic) NSMutableSet *responsesReceived;

@property (nonatomic) NSTimeInterval duplicatesResponseTimeout;

@property (nonatomic, getter=isConnected) BOOL connected;

@end

@implementation NBMJSONRPCClient

#pragma mark - Public

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        [self setupTransport];
        [self setupMessageLogic];
    }
    return self;
}

- (NBMRequest *)sendRequestWithMethod:(NSString *)method parameters:(id)parameters completion:(void (^)(NBMResponse *))responseBlock
{
//    NBMResponseBlock responseBlock = completion;
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
    [_requestsSent enumerateObjectsUsingBlock:^(NBMRequestPack* requestPack, BOOL* stop) {
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

//Responses

- (void)sendResponseWithError:(NBMResponseError *)responseError {
}

- (NBMResponse *)sendResponseWithResult:(id)result {
    return nil;
}

- (void)dealloc
{
    //secure transport closing, is needed?
    self.transport = nil;
    [self cancelAllRequest];
    //same as
    self.requestsSent = nil;
}

#pragma mark - Private

- (void)setupTransport
{
    _transport = [[NBMTransportChannel alloc] initWithURL:_url delegate:self];
    [_transport open];
}

- (void)setupMessageLogic
{
    //Requests cache (sent)
    _requestsSent = [NSMutableSet set];
    //Response cache (sent)
    _responsesSent = [NSMutableSet set];
    //Response cache (received)
    _responsesReceived = [NSMutableSet set];
    
    //Requests
    _requestId = 0;
    _requestTimeout = 5;
    _requestMaxRetries = 1;
    
    //Responses
    _responseTimeout = 5;
    _duplicatesResponseTimeout = 5;
}

- (void)decodeMessage:(NSDictionary *)messageDictionary
{
    messageDictionary = [self validateMessage:messageDictionary];
    //Message validation
    if (!messageDictionary) {
        return;
    }
    
    NSString *method = messageDictionary[kMethodKey];
    NSNumber *ack = messageDictionary[kIdKey];
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
    }
    
    //Response WITHOUT method already processed?
    if (!requestPack) {
        if ([self checkAndManageDuplicatedResponse:messageDictionary]) {
            return;
        }
        DDLogWarn(@"No callback was defined for this message: %@", [NSString nbm_stringFromJSONDictionary:messageDictionary]);
    }
    //Response WITHOUT method to process
    NBMResponse *response = [NBMResponse responseWithJSONDictionary:messageDictionary];
    [self processResponse:response requestPack:requestPack error:nil];
}

- (NSDictionary *)validateMessage:(NSDictionary *)messageDictionary
{
    NSString *version = messageDictionary[kJsonRpcKey];
    if (![version isEqualToString:kJsonRpcVersion]) {
        DDLogWarn(@"Invalid JSON-RPC version: %@", version);
        return nil;
    }
    
    //Response
    NSString *method = messageDictionary[kMethodKey];
    if (!method) {
        NSNumber *responseId = messageDictionary[kIdKey];
        if (!responseId) {
            DDLogWarn(@"No response id (ack) is defined: %@", messageDictionary);
            return nil;
        }
        id result = messageDictionary[kResultKey];
        id error = messageDictionary[kErrorKey];
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
    NSNumber *ack = responseDicitonary[kIdKey];
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
    
    //Set timeout
    NSTimeInterval timeout = _requestTimeout * pow(2, requestPack.retried);
    requestPack.timeout = timeout;
    requestPack.retried += 1;
    [_requestsSent addObject:requestPack];
    
    [self sendRequest:request];
}

- (void)sendRequest:(NBMRequest *)request
{
    NSDictionary *requestDictonary = [request toDictionary];
    [_transport sendMessage:requestDictonary];
}

- (void)cancelRequestPack:(NBMRequestPack *)requestPack
{
    //nil copied block (check if is needed)
    requestPack.responseBlock = nil;
    [requestPack clearTimeout];
    [_requestsSent removeObject:requestPack];
    
    // Start duplicated responses timeout
    NBMProcessedResponse *processedResponse = [[NBMProcessedResponse alloc] initWithAck:requestPack.request.requestId timeoutDelegate:self];
    [self storeProcessedResponse:processedResponse];
}

- (NBMRequestPack *)getRequestPackById:(NSNumber *)requestId
{
    __block NBMRequestPack *requestPack;
    [_requestsSent enumerateObjectsUsingBlock:^(NBMRequestPack* aRequestPack, BOOL *stop) {
        if ([requestPack.request.requestId isEqualToNumber:requestId]) {
            requestPack = aRequestPack;
            *stop = YES;
        }
    }];
    
    return requestPack;
}

- (void)processRequest:(NBMRequest *)request {
    [_delegate client:self didReceiveRequest:request];
}

#pragma mark Response

- (NBMProcessedResponse *)getProcessedResponseByAck:(NSNumber *)ack remove:(BOOL)remove
{
    __block NBMProcessedResponse *processedResponse;
    [_responsesReceived enumerateObjectsUsingBlock:^(NBMProcessedResponse *aProcessedResponse, BOOL *stop) {
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

- (void)processResponse:(NBMResponse *)response requestPack:(NBMRequestPack *)requestPack error:(NSError *)error{
    requestPack.responseBlock(response);
    [self cancelRequestPack:requestPack];
}

/**
 * Store the response to ignore duplicated messages later
 */
- (void)storeProcessedResponse:(NBMProcessedResponse *)processedResponse
{
    [processedResponse setTimeout:_duplicatesResponseTimeout];
    [_responsesReceived addObject:processedResponse];
}

#pragma mark TransportChannel delegate

- (void)channel:(NBMTransportChannel *)channel didChangeState:(NBMTransportChannelState)channelState
{
    switch (channelState) {
        case NBMTransportChannelStateClosed: {
            _connected = NO;
            break;
        }
        case NBMTransportChannelStateOpen: {
            _connected = YES;
            break;
        }
        case NBMTransportChannelStateError: {
            _connected = NO;
            break;
        }
        default: {
            break;
        }
    }
}

- (void)channel:(NBMTransportChannel *)channel didReceiveMessage:(NSDictionary *)messageDictionary
{
    [self decodeMessage:messageDictionary];
}

#pragma mark TimeoutableDelegate

- (void)timeoutFired:(id)timeoutable
{
    //Timeout fired on RequestPack
    if ([timeoutable isKindOfClass:[NBMRequestPack class]]) {
        NBMRequestPack *requestPack = (NBMRequestPack *)timeoutable;
        if (requestPack.retried < _requestMaxRetries) {
            [self sendRequestPack:requestPack retried:YES];
            return;
        }
    
        DDLogWarn(@"Request %@ has timed out!", requestPack.request);
        [self processResponse:nil requestPack:requestPack];
    }
    //Timeout fired on processed Response
    else if ([timeoutable isKindOfClass:[NBMProcessedResponse class]]) {
        NBMProcessedResponse *processedResponse = (NBMProcessedResponse *)timeoutable;
        //clear timeout is done in dealloc
        [_responsesReceived removeObject:processedResponse];
    }
}

@end
