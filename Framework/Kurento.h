//
//  Kurento.h
//  Kurento-iOS
//
//  Created by Marco Rossi on 18/09/15.
//  Copyright © 2015 Telecom Italia S.p.A All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for Kurento.
FOUNDATION_EXPORT double KurentoVersionNumber;

//! Project version string for Kurento.
FOUNDATION_EXPORT const unsigned char KurentoVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Kurento/PublicHeader.h>

//Web RTC
#import <Kurento/NBMWebRTCPeer.h>
#import <Kurento/NBMPeerConnection.h>

//JSON-RPC
#import <Kurento/NBMJSONRPCConstants.h>
#import <Kurento/NBMJSONRPCClient.h>

//JSON-RPC Messages
#import <Kurento/NBMMessage.h>
#import <Kurento/NBMRequest.h>
#import <Kurento/NBMResponse.h>
#import <Kurento/NBMResponseError.h>