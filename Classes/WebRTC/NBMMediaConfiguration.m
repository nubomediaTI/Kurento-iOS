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
