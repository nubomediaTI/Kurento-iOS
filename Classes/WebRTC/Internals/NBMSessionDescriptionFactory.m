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

#import "NBMSessionDescriptionFactory.h"

#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCSessionDescription.h>

@implementation NBMSessionDescriptionFactory

+ (RTCMediaConstraints *)offerConstraints {
    return [self offerConstraintsRestartIce:NO];
}

+ (RTCMediaConstraints *)offerConstraintsRestartIce:(BOOL)restartICE;
{
    // In the AppRTC example optional offer contraints are nil
    NSMutableDictionary *optional = [NSMutableDictionary dictionaryWithDictionary:[self optionalConstraints]];
    
    if (restartICE) {
        [optional setObject:@"true" forKey:@"IceRestart"];
    }
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:[self mandatoryConstraints]
                                                                             optionalConstraints:optional];
    
    return constraints;
}

+ (RTCMediaConstraints *)connectionConstraints
{
    //Add mandatory constraints?
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil
                                                                             optionalConstraints:[self optionalConstraints]];
    return constraints;
}

+ (RTCMediaConstraints *)videoConstraints
{
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
    return constraints;
}

+ (RTCSessionDescription *)conditionedSessionDescription:(RTCSessionDescription *)sessionDescription
                                              audioCodec:(NBMAudioCodec)audioCodec
                                              videoCodec:(NBMVideoCodec)videoCodec
                                          videoBandwidth:(NSUInteger)videoBandwidth
                                          audioBandwidth:(NSUInteger)audioBandwidth
{
    NSString *sdpString = nil;
    
    // Audio
    
    if (audioCodec == NBMAudioCodecOpus) {
        sdpString = sessionDescription.sdp;
    }
    else {
        sdpString = [self preferISACSimple:sessionDescription.sdp];
    }
    
    // Video
    
    if (videoCodec == NBMVideoCodecH264) {
        sdpString = [self preferH264:sdpString];
    }
    else {
        sdpString = [self preferVP8:sdpString];
    }
    
    // Bandwidth
    
    sdpString = [self constrainedSessionDescription:sdpString videoBandwidth:videoBandwidth audioBandwidth:audioBandwidth];
    
    return [[RTCSessionDescription alloc] initWithType:sessionDescription.type sdp:sdpString];
}

#pragma mark - Private

+ (NSDictionary *)constraintsForVideoFormat:(NBMVideoFormat)format
{
    return @{
             @"maxWidth": [NSString stringWithFormat:@"%d", format.dimensions.width],
             @"maxHeight": [NSString stringWithFormat:@"%d", format.dimensions.height],
             @"minWidth": @"240",
             @"minHeight": @"160"
             };
}

+ (NSDictionary *)mandatoryConstraints
{
    return @{
             @"OfferToReceiveAudio": @"true",
             @"OfferToReceiveVideo": @"true"
             };
}

+ (NSDictionary *)optionalConstraints
{
    return @{
             @"internalSctpDataChannels": @"true",
             @"DtlsSrtpKeyAgreement": @"true"
             };
}

+ (NSString *)preferISACSimple:(NSString *)sdp
{
    return [sdp stringByReplacingOccurrencesOfString:@"111 103" withString:@"103 111"];
}

+ (NSString *)constrainedSessionDescription:(NSString *)sdp videoBandwidth:(NSUInteger)videoBandwidth audioBandwidth:(NSUInteger)audioBandwidth
{
    // Modify the SDP's video & audio media sections to restrict the maximum bandwidth used.
    
    NSString *mAudioLinePattern = @"m=audio(.*)";
    NSString *mVideoLinePattern = @"m=video(.*)";
    
    NSString *constraintedSDP = [self limitBandwidth:sdp withPattern:mAudioLinePattern maximum:audioBandwidth];
    constraintedSDP = [self limitBandwidth:constraintedSDP withPattern:mVideoLinePattern maximum:videoBandwidth];
    
    return constraintedSDP;
}

+ (NSString *)limitBandwidth:(NSString *)sdp withPattern:(NSString *)mLinePattern maximum:(NSUInteger)bandwidthLimit
{
    NSString *cLinePattern = @"c=IN(.*)";
    NSError *error = nil;
    NSRegularExpression *mRegex = [[NSRegularExpression alloc] initWithPattern:mLinePattern options:0 error:&error];
    NSRegularExpression *cRegex = [[NSRegularExpression alloc] initWithPattern:cLinePattern options:0 error:&error];
    NSRange mLineRange = [mRegex rangeOfFirstMatchInString:sdp options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, [sdp length])];
    NSRange cLineSearchRange = NSMakeRange(mLineRange.location + mLineRange.length, [sdp length] - (mLineRange.location + mLineRange.length));
    NSRange cLineRange = [cRegex rangeOfFirstMatchInString:sdp options:NSMatchingWithoutAnchoringBounds range:cLineSearchRange];
    
    NSString *cLineString = [sdp substringWithRange:cLineRange];
    NSString *bandwidthString = [NSString stringWithFormat:@"b=AS:%d", (int)bandwidthLimit];
    
    return [sdp stringByReplacingCharactersInRange:cLineRange
                                        withString:[NSString stringWithFormat:@"%@\n%@", cLineString, bandwidthString]];
}

+ (NSString *)preferVideoCodec:(NSString *)codec inSDP:(NSString *)sdpString
{
    NSString *lineSeparator = @"\n";
    NSString *mLineSeparator = @" ";
    // Copied from PeerConnectionClient.java.
    // TODO(tkchin): Move this to a shared C++ file.
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[sdpString componentsSeparatedByString:lineSeparator]];
    NSInteger mLineIndex = -1;
    NSString *codecRtpMap = nil;
    // a=rtpmap:<payload type> <encoding name>/<clock rate>
    // [/<encoding parameters>]
    NSString *pattern = [NSString stringWithFormat:@"^a=rtpmap:(\\d+) %@(/\\d+)+[\r]?$", codec];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:nil];
    for (NSInteger i = 0; (i < lines.count) && (mLineIndex == -1 || !codecRtpMap); ++i) {
        NSString *line = lines[i];
        if ([line hasPrefix:@"m=video"]) {
            mLineIndex = i;
            continue;
        }
        NSTextCheckingResult *codecMatches = [regex firstMatchInString:line
                                                               options:0
                                                                 range:NSMakeRange(0, line.length)];
        if (codecMatches) {
            codecRtpMap = [line substringWithRange:[codecMatches rangeAtIndex:1]];
            continue;
        }
    }
    
    if (mLineIndex == -1) {
        NSLog(@"No m=video line, so can't prefer %@", codec);
        return sdpString;
    }
    
    if (!codecRtpMap) {
        NSLog(@"No rtpmap for %@", codec);
        return sdpString;
    }
    
    NSArray *origMLineParts = [lines[mLineIndex] componentsSeparatedByString:mLineSeparator];
    
    if (origMLineParts.count > 3) {
        NSMutableArray *newMLineParts = [NSMutableArray arrayWithCapacity:origMLineParts.count];
        NSInteger origPartIndex = 0;
        
        // Format is: m=<media> <port> <proto> <fmt> ...
        [newMLineParts addObject:origMLineParts[origPartIndex++]];
        [newMLineParts addObject:origMLineParts[origPartIndex++]];
        [newMLineParts addObject:origMLineParts[origPartIndex++]];
        [newMLineParts addObject:codecRtpMap];
        
        for (; origPartIndex < origMLineParts.count; ++origPartIndex) {
            if (![codecRtpMap isEqualToString:origMLineParts[origPartIndex]]) {
                [newMLineParts addObject:origMLineParts[origPartIndex]];
            }
        }
        NSString *newMLine = [newMLineParts componentsJoinedByString:mLineSeparator];
        [lines replaceObjectAtIndex:mLineIndex withObject:newMLine];
    }
    else {
        NSLog(@"Wrong SDP media description format: %@", lines[mLineIndex]);
    }
    
    return [lines componentsJoinedByString:lineSeparator];
}

+ (NSString *)preferVP8:(NSString *)sdpString
{
    return [self preferVideoCodec:@"VP8" inSDP:sdpString];
}

+ (NSString *)preferH264:(NSString *)sdpString
{
    return [self preferVideoCodec:@"H264" inSDP:sdpString];
}


@end
