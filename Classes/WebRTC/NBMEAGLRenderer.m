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


#import "NBMEAGLRenderer.h"
#import "NBMEAGLVideoViewContainer.h"

#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCVideoTrack.h>

@interface NBMEAGLRenderer() <RTCEAGLVideoViewDelegate>

@property (nonatomic, strong) NBMEAGLVideoViewContainer *containerView;
@property (nonatomic, strong) RTCEAGLVideoView *openGLView;
@property (nonatomic, assign) CGSize videoSize;
@property (atomic, assign) BOOL hasVideoData;

@end

@implementation NBMEAGLRenderer

- (instancetype)initWithDelegate:(id<NBMRendererDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _openGLView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectZero];
        _containerView = [[NBMEAGLVideoViewContainer alloc] initWithView:_openGLView];
        _openGLView.delegate = self;
    }
    
    return self;
}

#pragma mark - Public

- (void)setVideoTrack:(RTCVideoTrack *)videoTrack
{
    if (_videoTrack != videoTrack) {
        [_videoTrack removeRenderer:self.openGLView];
        _videoTrack = videoTrack;
        [_videoTrack addRenderer:self.openGLView];
    }
}

- (UIView *)rendererView
{
    return self.containerView;
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size
{
    self.videoSize = size;
    
    if (!_hasVideoData) {
        self.hasVideoData = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate rendererDidReceiveVideoData:self];
        });
    }
    
    self.containerView.videoSize = size;
    
    [self.delegate renderer:self streamDimensionsDidChange:size];
}

#pragma mark - RTCVideoRenderer

- (void)setSize:(CGSize)size
{
    // Do nothing.
}

- (void)renderFrame:(id<NSObject>)frame
{
    // Do nothing.
}

@end
