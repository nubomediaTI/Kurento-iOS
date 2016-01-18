//
//  ViewController.m
//  KurentoToolboxTestApp
//
//  Created by Marco Rossi on 09/11/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "ViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <KurentoToolbox/KurentoToolbox.h>

@interface ViewController ()<NBMRoomClientDelegate, NBMWebRTCPeerDelegate>

@property (nonatomic, strong) NBMWebRTCPeer *peer;
@property (nonatomic, strong) NBMRoomClient *roomClient;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *roomButtons;
@property (nonatomic, strong) IBOutlet UIButton *joinRoomBtn;

@end

static const int ddLogLevel = DDLogLevelVerbose;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NBMMediaConfiguration *mediaConfig = [NBMMediaConfiguration defaultConfiguration];
    NBMWebRTCPeer *web = [[NBMWebRTCPeer alloc] initWithDelegate:self configuration:nil];
    NBMRoom *room = [[NBMRoom alloc] initWithUsername:@"maross" roomName:@"mr5" roomURL:[NSURL URLWithString:@"http://kurento.teamlife.it:8080/room"]];
    self.roomClient = [[NBMRoomClient alloc] initWithRoom:room timeout:10 delegate:self];
    [self enableButtons:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.roomClient joinRoom:^(NSDictionary *peers, NSError *error) {
        
    }];
//    if (self.roomClient.connected) {
//        for (int i = 0; i<5; i++) {
//            [self.roomClient joinRoom];
//            [NSThread sleepForTimeInterval:5.0];
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableButtons:(BOOL)enable {
    for (UIButton* button in self.roomButtons) {
        button.enabled = enable;
    }
}

- (IBAction)joinRoom:(id)sender {
    if (self.roomClient.connected) {
        [self.roomClient joinRoom:^(NSDictionary *peers, NSError *error) {
            DDLogDebug(@"ROOM JOINED: peers: %@ - error: %@", peers, error);
        }];
    }
}

- (IBAction)leaveRoom:(id)sender {
    [self.roomClient leaveRoom:^(NSError *error) {
       DDLogDebug(@"ROOM LEAVED - error: %@", error);
    }];
}

#pragma mark Room Client Delegate 

- (void)client:(NBMRoomClient *)client isConnected:(BOOL)connected {
    if (connected) {
        [self enableButtons:connected];
    }
}

- (void)client:(NBMRoomClient *)client didFailWithError:(NSError *)error {
    DDLogVerbose(@"Client did fail with error: %@", error);
}

- (void)client:(NBMRoomClient *)client didJoinRoom:(NSError *)error {
    
}

- (void)client:(NBMRoomClient *)client didLeaveRoom:(NSError *)error {
    
}

#pragma mark - WebRTC Delegate

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateOffer:(RTCSessionDescription *)sdpOffer forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer hasICECandidate:(RTCICECandidate *)candidate forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webrtcPeer:(NBMWebRTCPeer *)peer iceStatusChanged:(RTCICEConnectionState)state ofConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didRemoveStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didGenerateAnswer:(RTCSessionDescription *)sdpAnswer forConnection:(NBMPeerConnection *)connection {
    
}

- (void)webRTCPeer:(NBMWebRTCPeer *)peer didAddStream:(RTCMediaStream *)remoteStream ofConnection:(NBMPeerConnection *)connection {
    
}

@end
