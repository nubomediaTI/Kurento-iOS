//
//  NBMMediaConfiguration.h
//  Kurento-iOS
//
//  Created by Marco Rossi on 30/11/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "NBMTypes.h"


@interface NBMMediaConfiguration : NSObject <NSCopying>

@property (nonatomic, assign) NBMRendererType rendererType;
@property (nonatomic, assign) NBMAudioCodec audioCodec;
@property (nonatomic, assign) NSUInteger audioBandwidth;
@property (nonatomic, assign) NBMVideoCodec videoCodec;
@property (nonatomic, assign) NSUInteger videoBandwidth;
@property (nonatomic, assign) NBMVideoFormat receiverVideoFormat;
@property (nonatomic, assign) NBMCameraPosition cameraPosition;

/*
 NBMAudioCodecOpus
 NBMVideoCodecVP8
 640x480 @ 30 fps, Bi-Planar Full Range
 Any camera 
 */
+ (instancetype)defaultConfiguration;

@end
