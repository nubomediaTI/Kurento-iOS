//
//  AppDelegate.m
//  KurentoToolboxTestApp
//
//  Created by Marco Rossi on 09/11/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <KurentoToolbox/KurentoToolbox.h>

@interface AppDelegate () <NBMJSONRPCClientDelegate, NBMWebRTCPeerDelegate>

@property (nonatomic, strong) NBMJSONRPCClient *client;
@property (nonatomic, strong) NBMWebRTCPeer *peer;

@end

@implementation AppDelegate

static const int ddLogLevel = DDLogLevelVerbose;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    NBMJSONRPCClient *client = [[NBMJSONRPCClient alloc] initWithURL:[NSURL URLWithString:@"http://10.214.146.32:8080/one2many"] delegate:self];
    self.client = client;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)client:(NBMJSONRPCClient *)client didFailWithError:(NSError *)error {
    
}


- (void)client:(NBMJSONRPCClient *)client didReceiveRequest:(NBMRequest *)request {
    
}

- (void)clientDidBecomeReady:(NBMJSONRPCClient *)client {
    NBMWebRTCPeer *peer = [[NBMWebRTCPeer alloc] initWithDelegate:self cameraPosition:1];
    self.peer = peer;
    [peer generateOffer:@"1"];

}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateOffer:(RTCSessionDescription *)sdpOffer forConnection:(NBMPeerConnection *)connection {
    NBMRequest *req = [NBMRequest requestWithMethod:@"viewer" parameters:@{@"sdpOffer" : sdpOffer.description}];
    [self.client sendRequest:req completion:^(NBMResponse *response) {
        DDLogDebug(@"response: %@", response);
    }];
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCICEConnectionState)state ofConnection:(NBMPeerConnection *)connection {
    
}

@end
