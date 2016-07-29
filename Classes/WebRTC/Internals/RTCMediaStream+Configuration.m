//
//  RTCMediaStream+Configuration.m
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
