//
//  NBMMediaConfiguration.m
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

#import "NBMMediaConfiguration.h"

@implementation NBMMediaConfiguration

+ (instancetype)defaultConfiguration {
    NBMMediaConfiguration *config = [[NBMMediaConfiguration alloc] init];
    config.rendererType = NBMRendererTypeOpenGLES;
    config.audioBandwidth = 0;
    config.videoBandwidth = 0;
    config.audioCodec = NBMAudioCodecOpus;
    config.videoCodec = NBMVideoCodecVP8;
    
    NBMVideoFormat format;
    format.dimensions = (CMVideoDimensions){640, 480};
    format.frameRate = 30;
    format.pixelFormat = NBMPixelFormat420f;
    config.receiverVideoFormat = format;
    
    config.cameraPosition = NBMCameraPositionFront;
    
    return config;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    NBMMediaConfiguration *copy = [[NBMMediaConfiguration alloc] init];
    copy.rendererType = self.rendererType;
    copy.audioBandwidth = self.audioBandwidth;
    copy.videoBandwidth = self.videoBandwidth;
    copy.audioCodec = self.audioCodec;
    copy.videoCodec = self.videoCodec;
    copy.receiverVideoFormat = self.receiverVideoFormat;
    copy.cameraPosition = self.cameraPosition;
    
    return copy;
}

@end
