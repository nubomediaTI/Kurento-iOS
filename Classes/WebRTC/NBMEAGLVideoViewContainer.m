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


#import "NBMEAGLVideoViewContainer.h"
#import <WebRTC/RTCEAGLVideoView.h>
#import <AVFoundation/AVFoundation.h>

@implementation NBMEAGLVideoViewContainer

- (instancetype)initWithView:(RTCEAGLVideoView *)view
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        _videoView = view;
        
        [self addSubview:view];
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    CGSize videoSize = self.videoSize;
    CGRect videoFrame = bounds;
    
    if (!CGSizeEqualToSize(videoSize, CGSizeZero)) {
        videoFrame = AVMakeRectWithAspectRatioInsideRect(videoSize, bounds);
    }
    
    self.videoView.frame = videoFrame;
}

- (void)setVideoSize:(CGSize)videoSize
{
    if (!CGSizeEqualToSize(videoSize, _videoSize)) {
        _videoSize = videoSize;
        [self setNeedsLayout];
    }
}


@end
