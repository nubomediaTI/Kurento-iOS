//
//  NBMTimeoutable.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 24/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NBMTimeoutable

@required
- (void)setTimeout:(NSTimeInterval) timeout;
- (void)clearTimeout;

@end

@protocol NBMTimeoutableDelegate

@required
- (void)timeoutFired:(id<NBMTimeoutable>)timeoutable;

@end

@interface NBMTimeoutable : NSObject<NBMTimeoutable> {
    NSTimeInterval _timeout;
    NSTimer *_timeoutTimer;
    __weak id<NBMTimeoutableDelegate> _timeoutDelegate;
}

@end

