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

#import "NBMJSONRPCUtilities.h"
#import "SBJson4.h"

@implementation NSDictionary (NBMUtilites)

+ (NSDictionary *)nbm_dictionaryWithJSONString:(NSString *)jsonString {
    NSParameterAssert(jsonString.length > 0);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return nil;
    }
    return dict;
}

+ (NSDictionary *)nbm_dictionaryWithJSONData:(NSData *)jsonData {
    NSError *error = nil;
    NSDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return nil;
    }
    return dict;
}

@end

@implementation NSString (NBMUtilites)

+ (NSString *)nbm_stringFromJSONDictionary:(NSDictionary *)jsonDictionary {
    SBJson4Writer *writer = [[SBJson4Writer alloc] init];
    NSString *json = [writer stringWithObject:jsonDictionary];
    return json;
//    NSError *error = nil;
//    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
//    if (error) {
//        NSLog(@"Error parsing Data: %@", error.localizedDescription);
//        return nil;
//    }
//    return [self nbm_stringFromJSONData:data];
}

+ (NSString *)nbm_stringFromJSONData:(NSData *)jsonData
{
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end