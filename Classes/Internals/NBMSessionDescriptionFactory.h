//
//  NBMSessionDescriptionFactory.h
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 24/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCMediaConstraints;

@interface NBMSessionDescriptionFactory : NSObject

+ (RTCMediaConstraints *)offerConstraints;

+ (RTCMediaConstraints *)connectionConstraints;

+ (RTCMediaConstraints *)videoConstraints;

@end
