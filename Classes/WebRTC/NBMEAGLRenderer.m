//
//  NBMEAGLRenderer.m
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


#import "NBMEAGLRenderer.h"
#import "NBMEAGLVideoViewContainer.h"

#import "RTCEAGLVideoView.h"
#import "RTCVideoTrack.h"

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

- (void)renderFrame:(RTCI420Frame *)frame
{
    // Do nothing.
}

@end
