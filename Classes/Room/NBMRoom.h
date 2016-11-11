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

typedef NS_ENUM(NSInteger, NBMRoomErrorCode) {
    NBMUserGenericRoomErrorCode = 101,
    NBMUserNotFoundRoomErrorCode = 102,
    NBMUserClosedRoomErrorCode = 103,
    NBMExistingUserInRoomRoomErrorCode = 104,
    
    NBMRoomGenericErrorRoomErrorCode = 201,
    NBMRoomNotFoundRoomErrorCode = 202,
    NBMRoomClosedRoomErrorCode = 203,
    NBMRoomCannotBeCreatedRoomErrorCode = 204,
    
    NBMMediaGenericErrorRoomErrorCode = 301,
    NBMMediaSdpErrorRoomErrorCode = 302,
    NBMMediaEndpointErrorRoomErrorCode = 303,
    NBMMediaWebRtcEndpointErrorRoomErrorCode = 304,
    NBMMediaRtpEndpointErrorRoomErrorCode = 305,
    NBMMediaNotAWebEndpointRoomErrorCode = 306,
    NBMMuteErrorRoomErrorCode = 307,
    
    NBMTransportRequestErrorRoomErrorCode = 801,
    NBMTransportResponseErrorRoomErrorCode = 802,
    NBMTransportErrorRoomErrorCode = 803,
    
    NBMGenericErrorRoomErrorCode = 999
};

@class NBMPeer;

@interface NBMRoom : NSObject

- (instancetype)initWithUsername:(NSString *)username roomName:(NSString *)name roomURL:(NSURL *)url dataChannels:(BOOL)dataChannels;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NBMPeer *localPeer;
@property (nonatomic, strong, readonly) NSSet *peers;
@property (nonatomic, assign, readonly) BOOL dataChannels;

@end
