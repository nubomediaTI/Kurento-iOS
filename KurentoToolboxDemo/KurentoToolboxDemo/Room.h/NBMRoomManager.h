//
//  NBMRoomManager.h
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

- (void)roomManager:(NBMRoomManager *)broker didAddDataChannel:(RTCDataChannel *)dataChannel ofPeer:(NBMPeer *)remotePeer;

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
