//
//  NBMMessage.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 24/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NBMMessage <NSObject>

- (NSDictionary *)toJSONDictionary;
@optional
- (NSString *)toJSONString;

@end

