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

@class NBMTreeEndpoint;
@class NBMTreeManager;

@protocol NBMTreeManagerDelegate <NSObject>

- (void)treeManager:(NBMTreeManager *)broker didAddLocalStream:(RTCMediaStream *)localStream;

- (void)treeManager:(NBMTreeManager *)broker didRemoveLocalStream:(RTCMediaStream *)localStream;

- (void)treeManager:(NBMTreeManager *)broker didAddStream:(RTCMediaStream *)remoteStream;

- (void)treeManager:(NBMTreeManager *)broker didRemoveStream:(RTCMediaStream *)remoteStream;

- (void)treeManager:(NBMTreeManager *)broker didFailWithError:(NSError *)error;

- (void)treeManager:(NBMTreeManager *)broker iceStatusChanged:(RTCIceConnectionState)state;

@end

@interface NBMTreeManager : NSObject

@property (nonatomic, strong) NSURL *treeURL;
@property (nonatomic, weak) id<NBMTreeManagerDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *treeId;
@property (nonatomic, strong, readonly) RTCMediaStream *mediaStream;
@property (nonatomic, assign, readonly) NBMCameraPosition cameraPosition;

@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;

- (instancetype)initWithTreeURL:(NSURL *)treeURL delegate:(id<NBMTreeManagerDelegate>)delegate;

- (void)startMasteringTree:(NSString *)treeId completion:(void (^)(NSError *error))block;
- (void)stopMasteringTree:(NSString *)treeId completion:(void (^)(NSError *error))block;

- (void)startViewingTree:(NSString *)treeId completion:(void (^)(NSError *error))block;
- (void)stopViewingTree:(NSString *)treeId completion:(void (^)(NSError *error))block;

//WebRTC & Media

- (void)selectCameraPosition:(NBMCameraPosition)cameraPosition;

- (BOOL)isVideoEnabled;

- (void)enableVideo:(BOOL)enable;

- (BOOL)isAudioEnabled;

- (void)enableAudio:(BOOL)enable;

@end
