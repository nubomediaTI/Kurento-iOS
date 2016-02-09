//
//  NBMMediaConfiguration.h
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
 */
+ (instancetype)defaultConfiguration;

@end
