//
//  NBMRequest.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBMMessage.h"

@interface NBMRequest : NSObject  <NBMMessage>

@property (nonatomic, readonly) NSNumber *requestId;
@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, readonly) id parameters;

+ (instancetype)requestWithMethod:(NSString *)method
                       parameters:(id)parameters;

@end
