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

#import <Foundation/Foundation.h>

@class NBMTreeClient;
@class RTCIceCandidate;

@protocol NBMTreeClientDelegate <NSObject>

//Connection

- (void)client:(NBMTreeClient *)client isConnected:(BOOL)connected;
- (void)client:(NBMTreeClient *)client didFailWithError:(NSError *)error;

//Events

/**
 *  Event sent when a new ICE candidate is received from Kurento Media Server.
 *
 *  @param client    The current NBMTreeClient object.
 *  @param candidate The RTCICECandidate object received.
 *  @param sinkId    Sink id to which belongs the candidate, 'nil' when the candidate is referred to the tree source.
 *  @param treeId    Tree id to which belongs this candidate.
 */
- (void)client:(NBMTreeClient *)client iceCandidateReceived:(RTCIceCandidate *)candidate ofSink:(NSString *)sinkId tree:(NSString *)treeId;

@end
