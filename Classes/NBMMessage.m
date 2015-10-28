//
//  NBMMessage.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMMessage.h"
#import "NBMJSONRPCConstants.h"

@implementation NBMMessage {

}

@synthesize sessionId;

+ (NSString *)version {
    return kJsonRpcVersion;
}

- (NSString *)JSONString
{
    //To override
    return nil;
}

- (NSDictionary *)toDictionary
{
    return nil;
}

- (id)initWithJSONDictionary:(NSDictionary *)json
{
    return nil;
}

@end
