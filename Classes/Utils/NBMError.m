//
//  NBMError.m
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

#import "NBMError.h"

static NSString* const NBMErrorDomain = @"eu.nubomediaTI.KurentoToolbox";

@implementation NBMError

+ (NSString *)errorDomain {
    return NBMErrorDomain;
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message {
    return [self errorWithCode:code message:message underlyingError:nil];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message underlyingError:(NSError *)underlyingError {
    return [self errorWithCode:code message:message userInfo:nil underlyingError:underlyingError];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message userInfo:(NSDictionary *)userInfo underlyingError:(NSError *)underlyingError {
    NSMutableDictionary *fullUserInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    [NBMError dictionary:fullUserInfo setObject:message forKey:NSLocalizedDescriptionKey];
    [NBMError dictionary:fullUserInfo setObject:underlyingError forKey:NSUnderlyingErrorKey];
    userInfo = ([fullUserInfo count] > 0 ? [fullUserInfo copy] : nil);
    
    NSError *error = [NSError errorWithDomain:[self errorDomain] code:code userInfo:userInfo];
    
    return error;
}

#pragma mark - Utility

+ (void)dictionary:(NSMutableDictionary *)dictionary setObject:(id)object forKey:(id<NSCopying>)key {
    if (object && key) {
        [dictionary setObject:object forKey:key];
    }
}

@end
