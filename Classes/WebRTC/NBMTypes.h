//
//  NBMTypes.h
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
