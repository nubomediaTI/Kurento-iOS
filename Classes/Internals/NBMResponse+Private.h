//
//  NBMResponse+Private.h

//  KurentoClient-iOS
//
//  Created by Marco Rossi on 20/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMResponse.h"

@interface NBMResponse ()

@property (nonatomic, readwrite) NSNumber *responseId;
@property (nonatomic, readwrite) id result;
@property (nonatomic, readwrite) NBMResponseError *error;

+ (instancetype)responseWithJSONDictionary:(NSDictionary *)json;

@end
