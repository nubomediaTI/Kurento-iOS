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

#import "RTCMediaStream+Configuration.h"
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCVideoTrack.h>

@implementation RTCMediaStream (Configuration)

- (BOOL)isAudioEnabled
{
    RTCAudioTrack *audioTrack = [self.audioTracks firstObject];
    return audioTrack ? audioTrack.isEnabled : YES;
}

- (void)setAudioEnabled:(BOOL)audioEnabled
{
    RTCAudioTrack *audioTrack = [self.audioTracks firstObject];
    [audioTrack setIsEnabled:audioEnabled];
}

- (BOOL)isVideoEnabled
{
    RTCVideoTrack *videoTrack = [self.videoTracks firstObject];
    return videoTrack ? videoTrack.isEnabled : YES;
}

- (void)setVideoEnabled:(BOOL)videoEnabled
{
    RTCVideoTrack *videoTrack = [self.videoTracks firstObject];
    [videoTrack setIsEnabled:videoEnabled];
}


@end
