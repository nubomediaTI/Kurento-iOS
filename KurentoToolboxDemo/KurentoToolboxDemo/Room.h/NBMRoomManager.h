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
#import <WebRTC/RTCPeerConnection.h>

@class NBMRoomManager;
@class RTCMediaStream;
@class NBMRoom;
@class NBMMediaConfiguration;

// Provides information about connected streams, errors and final disconnections.
@protocol NBMRoomManagerDelegate<NSObject>

- (void)roomManagerDidFinish:(NBMRoomManager *)broker;

- (void)roomManager:(NBMRoomManager *)broker didAddLocalStream:(RTCMediaStream *)localStream;

- (void)roomManager:(NBMRoomManager *)broker didRemoveLocalStream:(RTCMediaStream *)localStream;

- (void)roomManager:(NBMRoomManager *)broker didAddStream:(RTCMediaStream *)remoteStream ofPeer:(NBMPeer *)remotePeer;

- (void)roomManager:(NBMRoomManager *)broker didRemoveStream:(RTCMediaStream *)remoteStream ofPeer:(NBMPeer *)remotePeer;

- (void)roomManager:(NBMRoomManager *)broker peerJoined:(NBMPeer *)peer;

- (void)roomManager:(NBMRoomManager *)broker peerLeft:(NBMPeer *)peer;

- (void)roomManager:(NBMRoomManager *)broker peerEvicted:(NBMPeer *)peer;

- (void)roomManager:(NBMRoomManager *)broker roomJoined:(NSError *)error;

- (void)roomManager:(NBMRoomManager *)broker messageReceived:(NSString *)message ofPeer:(NBMPeer *)peer;

- (void)roomManagerPeerStatusChanged:(NBMRoomManager *)broker;

- (void)roomManager:(NBMRoomManager *)broker didFailWithError:(NSError *)error;

- (void)roomManager:(NBMRoomManager *)broker iceStatusChanged:(RTCIceConnectionState)state ofPeer:(NBMPeer *)peer;

- (void)roomManager:(NBMRoomManager *)broker didAddDataChannel:(RTCDataChannel *)dataChannel;

@end

@interface NBMRoomManager : NSObject

@property (nonatomic, weak) id<NBMRoomManagerDelegate> delegate;
@property (nonatomic, strong, readonly) RTCMediaStream *localStream;
@property (nonatomic, strong, readonly) NBMPeer *localPeer;
@property (nonatomic, strong, readonly) NSArray *remotePeers;
@property (nonatomic, strong, readonly) NSArray *remoteStreams;
@property (nonatomic, assign, readonly) NBMCameraPosition cameraPosition;

@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;
@property (nonatomic, assign, readonly, getter=isJoined) BOOL joined;

- (instancetype)initWithDelegate:(id<NBMRoomManagerDelegate>)delegate;

- (void)joinRoom:(NBMRoom *)room withConfiguration:(NBMMediaConfiguration *)configuration;

- (void)leaveRoom:(void (^)(NSError *error))block;

- (void)publishVideo:(void (^)(NSError *error))block loopback:(BOOL)doLoopback;

- (void)unpublishVideo:(void (^)(NSError *error))block;

- (void)receiveVideoFromPeer:(NBMPeer *)peer completion:(void (^)(NSError *error))block;

- (void)unsubscribeVideoFromPeer:(NBMPeer *)peer completion:(void (^)(NSError *error))block;

//WebRTC & Media

- (void)selectCameraPosition:(NBMCameraPosition)cameraPosition;

- (BOOL)isVideoEnabled;

- (void)enableVideo:(BOOL)enable;

- (BOOL)isAudioEnabled;

- (void)enableAudio:(BOOL)enable;
@end
