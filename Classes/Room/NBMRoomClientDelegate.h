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

@class NBMRoomClient;
@class NBMRoom;
@class NBMPeer;
@class RTCICECandidate;

@protocol NBMRoomClientDelegate <NSObject>

@optional
//Connection
- (void)client:(NBMRoomClient *)client isConnected:(BOOL)connected;
- (void)client:(NBMRoomClient *)client didFailWithError:(NSError *)error;

//Room API
- (void)client:(NBMRoomClient *)client didJoinRoom:(NSError *)error;
- (void)client:(NBMRoomClient *)client didLeaveRoom:(NSError *)error;

- (void)client:(NBMRoomClient *)client didPublishVideo:(NSString *)sdpAnswer loopback:(BOOL)doLoopback error:(NSError *)error;
- (void)client:(NBMRoomClient *)client didUnPublishVideo:(NSError *)error;

- (void)client:(NBMRoomClient *)client didReceiveVideoFrom:(NBMPeer *)peer sdpAnswer:(NSString *)sdpAnswer error:(NSError *)error;
- (void)client:(NBMRoomClient *)client didUnsubscribeVideoFrom:(NBMPeer *)peer sdpAnswer:(NSString *)sdpAnswer error:(NSError *)error;

- (void)client:(NBMRoomClient *)client didSentICECandidate:(NSError *)error forPeer:(NBMPeer *)peer;

- (void)client:(NBMRoomClient *)client didSentMessage:(NSError *)error;

- (void)client:(NBMRoomClient *)client didSentCustomRequest:(NSError *)error;

//Room events
- (void)client:(NBMRoomClient *)client participantJoined:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client participantLeft:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client participantEvicted:(NBMPeer *)peer;

- (void)client:(NBMRoomClient *)client participantPublished:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client participantUnpublished:(NBMPeer *)peer;

- (void)client:(NBMRoomClient *)client didReceiveICECandidate:(RTCIceCandidate *)candidate fromParticipant:(NBMPeer *)peer;

- (void)client:(NBMRoomClient *)client didReceiveMessage:(NSString *)message fromParticipant:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client mediaErrorOccurred:(NSError *)error;
- (void)client:(NBMRoomClient *)client roomWasClosed:(NBMRoom *)room;


@end
