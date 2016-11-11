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

#import <CoreMedia/CoreMedia.h>

/**
 *  Camera position types
 */
typedef NS_ENUM(NSUInteger, NBMCameraPosition) {
    /**
     *  Any camera position available.
     */
    NBMCameraPositionAny = 0,
    /**
     *  Back camera position.
     */
    NBMCameraPositionBack = 1,
    /**
     *  Front camera position.
     */
    NBMCameraPositionFront = 2
};

typedef NS_OPTIONS(NSUInteger, NBMRendererType)
{
    /* Native renderer, supports acceleration on iOS 8+ */
    NBMRendererTypeSampleBuffer,
    /* OpenGL renderer */
    NBMRendererTypeOpenGLES,
    NBMRendererTypeQuartz
};

typedef NS_ENUM(OSType, NBMPixelFormat) {
    /**
     *   Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct
     */
    NBMPixelFormat420f = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
    /**
     *  Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct
     */
    NBMPixelFormat420v = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
    
    /**
     *  32 bit BGRA
     */
    NBMPixelFormatBGRA = kCVPixelFormatType_32BGRA,
    /**
     *  32 bit ARGB
     */
    NBMPixelFormatARGB = kCVPixelFormatType_32ARGB,
};

typedef struct NBMVideoFormat {
    CMVideoDimensions dimensions;
    NBMPixelFormat pixelFormat;
    double frameRate;
} NBMVideoFormat;

typedef NS_ENUM(NSUInteger, NBMVideoCodec)
{
    /* Stable, software VP8 encode & decode via libvpx */
    NBMVideoCodecVP8 = 0,
    /* Experimental, hardware H.264 encode & decode via VideoToolbox. */
    NBMVideoCodecH264 = 1
};

typedef NS_ENUM(NSUInteger, NBMAudioCodec)
{
    /* The Opus audio codec is wideband, and higher quality. */
    NBMAudioCodecOpus = 0,
    /* ISAC is lower quality, but more compatible. */
    NBMAudioCodecISAC = 1
};
