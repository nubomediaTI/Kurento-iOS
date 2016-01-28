//
//  NBMRoomClientDelegate.h
//  Copyright (c) 2016 Telecom Italia S.p.A. All rights reserved.
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

@class NBMRoomClient;
@class NBMRoom;
@class NBMPeer;
@class RTCICECandidate;

@protocol NBMRoomClientDelegate <NSObject>

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
- (void)client:(NBMRoomClient *)client partecipantJoined:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client partecipantLeft:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client partecipantEvicted:(NBMPeer *)peer;

- (void)client:(NBMRoomClient *)client partecipantPublished:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client partecipantUnpublished:(NBMPeer *)peer;

- (void)client:(NBMRoomClient *)client didReceiveICECandidate:(RTCICECandidate *)candidate fromPartecipant:(NBMPeer *)peer;

- (void)client:(NBMRoomClient *)client didReceiveMessage:(NSString *)message fromPartecipant:(NBMPeer *)peer;
- (void)client:(NBMRoomClient *)client mediaErrorOccurred:(NSError *)error;
- (void)client:(NBMRoomClient *)client roomWasClosed:(NBMRoom *)room;


@end
