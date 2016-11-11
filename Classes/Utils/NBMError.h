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

@interface NBMError : NSObject

+ (NSString *)errorDomain;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message underlyingError:(NSError *)underlyingError;

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message userInfo:(NSDictionary *)userInfo underlyingError:(NSError *)underlyingError;

#ifndef DOXYGEN_SHOULD_SKIP_THIS
// Disallow init and don't add to documentation
- (id)init __attribute__(
                         (unavailable("init is not a supported initializer for this class.")));
#endif /* DOXYGEN_SHOULD_SKIP_THIS */

@end
