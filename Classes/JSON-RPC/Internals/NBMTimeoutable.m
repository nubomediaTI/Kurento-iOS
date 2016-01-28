//
//  NBMTimeoutable.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 24/10/15.
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMTimeoutable.h"

@interface NBMTimerTarget : NSObject

@property(weak, nonatomic) id realTarget;
@property (nonatomic) SEL selector;

- (instancetype)initWithTarget:(id)target selector:(SEL)selector;
- (void)timerFired:(NSTimer*)theTimer;

@end

@implementation NBMTimerTarget

- (instancetype)initWithTarget:(id)target selector:(SEL)selector
{
    self = [super init];
    if (!self) return nil;
    
    _realTarget = target;
    _selector = selector;
    
    return self;
}

- (void)timerFired:(NSTimer*)theTimer
{
    // This line cause compiler warning
    // http://stackoverflow.com/a/20058585
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.realTarget performSelector:self.selector withObject:theTimer];
#pragma clang diagnostic pop
    //((void (*)(id, SEL))[self.realTarget methodForSelector:self.selector])(self.realTarget, self.selector);
}

@end

@implementation NBMTimeoutable

- (void)dealloc {
    [self clearTimeout];
}

#pragma mark NBMTimeoutable protocol

- (void)setTimeout:(NSTimeInterval)timeout
{
    [self clearTimeout];
    _timeout = timeout;
    NBMTimerTarget *target = [[NBMTimerTarget alloc] initWithTarget:self selector:@selector(onTimeout:)];
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeout target:target selector:@selector(timerFired:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _timeoutTimer = timer;
}

- (void)clearTimeout
{
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}

- (void)onTimeout:(NSTimer *)timer
{
    [_timeoutDelegate timeoutFired:self];
}

@end
