//
//  NBMRequest+Private.h

//  KurentoClient-iOS
//
//  Created by Marco Rossi on 15/10/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMRequest.h"

@interface NBMRequest ()

@property (nonatomic, readwrite) NSNumber *requestId;
@property (nonatomic, copy, readwrite) NSString *method;
@property (nonatomic, readwrite) id parameters;

+ (instancetype)requestWithJSONDicitonary:(NSDictionary *)json;

@end
