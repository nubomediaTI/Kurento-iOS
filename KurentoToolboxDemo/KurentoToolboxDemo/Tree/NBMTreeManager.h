//
//  NBMTreeManager.h
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
