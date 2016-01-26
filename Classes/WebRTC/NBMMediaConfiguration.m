//
//  NBMMediaConfiguration.m
//  Kurento-iOS
//
//  Created by Marco Rossi on 30/11/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMMediaConfiguration.h"

@implementation NBMMediaConfiguration

+ (instancetype)defaultConfiguration {
    NBMMediaConfiguration *config = [[NBMMediaConfiguration alloc] init];
    config.rendererType = NBMRendererTypeSampleBuffer;
    config.audioBandwidth = 0;
    config.videoBandwidth = 0;
    config.audioCodec = NBMAudioCodecOpus;
    config.videoCodec = NBMVideoCodecVP8;
    
    NBMVideoFormat format;
    format.dimensions = (CMVideoDimensions){640, 480};
    format.frameRate = 30;
    format.pixelFormat = NBMPixelFormat420f;
    config.receiverVideoFormat = format;
    
    config.cameraPosition = NBMCameraPositionAny;
    
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
