//
//  KurentoToolbox.h
//  Copyright (c) 2015 Telecom Italia S.p.A. All rights reserved.
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

//Room
#import <KurentoToolbox/NBMRoom.h>
#import <KurentoToolbox/NBMPeer.h>
#import <KurentoToolbox/NBMRoomClient.h>
#import <KurentoToolbox/NBMRoomClientDelegate.h>

//Web RTC
#import <KurentoToolbox/NBMWebRTCPeer.h>
#import <KurentoToolbox/NBMPeerConnection.h>

//JSON-RPC
#import <KurentoToolbox/NBMJSONRPCClient.h>
#import <KurentoToolbox/NBMJSONRPCClientDelegate.h>

//JSON-RPC Messages
#import <KurentoToolbox/NBMMessage.h>
#import <KurentoToolbox/NBMRequest.h>
#import <KurentoToolbox/NBMResponse.h>

//Errors
#import <KurentoToolbox/NBMError.h>
#import <KurentoToolbox/NBMJSONRPCError.h>
#import <KurentoToolbox/NBMJSONRPCClientError.h>
#import <KurentoToolbox/NBMRoomError.h>
#import <KurentoToolbox/NBMRoomClientError.h>

//libjingle Headers
#import <KurentoToolbox/RTCAudioSource.h>
#import <KurentoToolbox/RTCAudioTrack.h>
#import <KurentoToolbox/RTCAVFoundationVideoSource.h>
#import <KurentoToolbox/RTCDataChannel.h>
#import <KurentoToolbox/RTCEAGLVideoView.h>
#import <KurentoToolbox/RTCFileLogger.h>
#import <KurentoToolbox/RTCI420Frame.h>
#import <KurentoToolbox/RTCICECandidate.h>
#import <KurentoToolbox/RTCICEServer.h>
#import <KurentoToolbox/RTCLogging.h>
#import <KurentoToolbox/RTCMediaConstraints.h>
#import <KurentoToolbox/RTCMediaSource.h>
#import <KurentoToolbox/RTCMediaStream.h>
#import <KurentoToolbox/RTCMediaStreamTrack.h>
#import <KurentoToolbox/RTCOpenGLVideoRenderer.h>
#import <KurentoToolbox/RTCPair.h>
#import <KurentoToolbox/RTCPeerConnection.h>
#import <KurentoToolbox/RTCPeerConnectionDelegate.h>
#import <KurentoToolbox/RTCPeerConnectionInterface.h>
#import <KurentoToolbox/RTCPeerConnectionFactory.h>
#import <KurentoToolbox/RTCSessionDescription.h>
#import <KurentoToolbox/RTCSessionDescriptionDelegate.h>
#import <KurentoToolbox/RTCStatsDelegate.h>
#import <KurentoToolbox/RTCStatsReport.h>
#import <KurentoToolbox/RTCTypes.h>
#import <KurentoToolbox/RTCVideoCapturer.h>
#import <KurentoToolbox/RTCVideoRenderer.h>
#import <KurentoToolbox/RTCVideoSource.h>
#import <KurentoToolbox/RTCVideoTrack.h>