//
//  NBMUtilities.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 18/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NBMUtilites)

+ (NSDictionary *)nbm_dictionaryWithJSONString:(NSString *)jsonString;
+ (NSDictionary *)nbm_dictionaryWithJSONData:(NSData *)jsonData;

@end

@interface NSString (NBMUtilites)

+ (NSString *)nbm_stringFromJSONDictionary:(NSDictionary *)jsonDictionary;
+ (NSString *)nbm_stringFromJSONData:(NSData *)jsonData;

@end

