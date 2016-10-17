//
//  NBMRoomVideoViewController.m
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
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

#import "NBMRoomVideoViewController.h"

#import "NBMRoomManager.h"
#import "NBMPeerViewCell.h"
#import "NBMPeersFlowLayout.h"
#import "NBMRenderer.h"
#import "NBMPeer.h"

#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCDataChannel.h>

#import "MBProgressHUD.h"
#import "NBMToolbar.h"
#import "NBMButton.h"
#import "NBMButtonFactory.h"

NSString *const kPeerCollectionViewCellIdentifier = @"PeerCollectionViewCellIdentifier";


@interface NBMRoomVideoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NBMRoomManagerDelegate, NBMRendererDelegate, NBMPeerViewCellDelegate, RTCDataChannelDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *peersCollectionView;
@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;

@property (nonatomic, weak) IBOutlet NBMToolbar *toolbar;
@property (nonatomic, weak) NBMButton *videoButton;
@property (nonatomic, weak) NBMButton *audioButton;


@property (nonatomic, strong) NBMRoomManager *roomManager;
@property (nonatomic, strong, readonly) NSArray *allPeers;
@property (nonatomic, strong) NBMMediaConfiguration *mediaConfiguration;

@property (nonatomic, strong) id<NBMRenderer> localRenderer;
@property (nonatomic, strong) NSMutableArray *remoteRenderers;
@property (nonatomic, strong) NSMutableDictionary *peerIdToRenderer;

@property (nonatomic, assign) UIInterfaceOrientation lastInterfaceOrientation;

@property (nonatomic, assign) BOOL publishing;
@property (nonatomic, assign) BOOL unpublishing;

@end

@implementation NBMRoomVideoViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _remoteRenderers = [NSMutableArray array];
    _peerIdToRenderer = [NSMutableDictionary dictionary];
    _mediaConfiguration = [NBMMediaConfiguration defaultConfiguration];
}

- (void)dealloc {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    [self removeRoomManagerObservers];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self informObserversOfOrientation:toInterfaceOrientation];
}

- (BOOL)prefersStatusBarHidden
{
    id <NBMRenderer> remoteRenderer = [self.remoteRenderers firstObject];
    return remoteRenderer.videoTrack != nil;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showJoinProgressHUD];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideProgressHUD:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.peersCollectionView.backgroundColor = [UIColor blackColor];
    
    [self setupToolbar];
    
    self.roomManager = [[NBMRoomManager alloc] initWithDelegate:self];
    
    [self.roomManager joinRoom:self.room withConfiguration:nil];
    
    [self addRoomManagerObservers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = self.room.name;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.roomManager leaveRoom:nil];
}

- (void)setupToolbar {
    
    __weak __typeof(self)weakSelf = self;
    
//    NBMButton *videoEnable = [NBMButtonFactory buttonWithNormalText:@"Disable video" selectedText:@"Enable video"];
    NBMButton *videoEnable = [NBMButtonFactory videoEnable];
    self.videoButton = videoEnable;
    [self.toolbar addButton:videoEnable action:^(UIButton *sender) {
        BOOL videoEnabled = [weakSelf.roomManager isVideoEnabled];
        [weakSelf enableVideo:!videoEnabled];
    }];
    
//    NBMButton *audioEnable = [NBMButtonFactory buttonWithNormalText:@"Disable audio" selectedText:@"Enable audio"];
    NBMButton *audioEnable = [NBMButtonFactory auidoEnable];
    self.audioButton = audioEnable;
    [self.toolbar addButton:audioEnable action:^(UIButton *sender) {
        BOOL audioEnabled = [weakSelf.roomManager isAudioEnabled];
        [weakSelf.roomManager enableAudio:!audioEnabled];
    }];
        
    NBMButton *streamEnable = [NBMButtonFactory buttonWithNormalText:@"Disable stream" selectedText:@"Enable stream"];
    [self.toolbar addButton:streamEnable action:^(UIButton *sender) {
        BOOL publish = weakSelf.roomManager.localPeer.streams.count > 0 ? NO : YES;
        if (publish) {
            if (weakSelf.publishing || weakSelf.unpublishing) {
                [(NBMButton *)sender setPressed:YES];
                return;
            }
            weakSelf.publishing = YES;
            [weakSelf.roomManager publishVideo:^(NSError *error) {
                weakSelf.publishing = NO;
                if (!error) {

                }
            } loopback:NO];
        } else {
            if (weakSelf.unpublishing || weakSelf.publishing) {
                [(NBMButton *)sender setPressed:NO];
                return;
            }
            weakSelf.unpublishing = YES;
            [weakSelf.roomManager unpublishVideo:^(NSError *error) {
                weakSelf.unpublishing = NO;
                if (!error) {

                }
            }];
        }
    }];
    
    [self.toolbar updateItems];
}

- (void)enableVideo:(BOOL)enable {
    [self.roomManager enableVideo:enable];
    [self updatePeer:self.room.localPeer block:^(NBMPeerViewCell *cell) {
        [cell enableVideo:enable];
    }];
}

- (void)enableStreamButtons:(BOOL)enabled {
    self.videoButton.enabled = enabled;
    self.videoButton.pressed = !enabled;
    self.audioButton.enabled = enabled;
    self.audioButton.pressed = !enabled;
}

#pragma mark - Progress HUD

- (void)showJoinProgressHUD {
    [self hideProgressHUD:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = [NSString stringWithFormat:@"Joining %@ room", self.room.name];
}

- (void)showSuccessHUD:(NSString *)string {
    [self hideProgressHUD:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    hud.labelText = string;
    [hud hide:YES afterDelay:0.3f];
}

- (void)showErrorHUD:(NSString *)string {
    [self hideProgressHUD:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [[UIImage imageNamed:@"error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    hud.labelText = string;
    [hud hide:YES afterDelay:0.3f];
}

- (void)showInfoHUD:(NSString *)string {
    [self hideProgressHUD:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [[UIImage imageNamed:@"info"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    hud.labelText = string;
    [hud hide:YES afterDelay:0.3f];
}

- (void)hideProgressHUD:(BOOL)animated {
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:animated];
}

#pragma mark - Private

- (void)addRoomManagerObservers {
    [self.roomManager addObserver:self forKeyPath:@"connected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.roomManager addObserver:self forKeyPath:@"joined" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)removeRoomManagerObservers {
    [self.roomManager removeObserver:self forKeyPath:@"connected"];
    [self.roomManager removeObserver:self forKeyPath:@"joined"];
}

- (void)informObserversOfOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // Due to an odd implementation detail in RTCVideoCaptureIosObjC (rtc_video_capture_ios_objc.m),
    // we must inform the capturer of orientation changes by posting a 'StatusBarOrientationDidChange' notification.
    
    if (toInterfaceOrientation != self.lastInterfaceOrientation) {
        self.lastInterfaceOrientation = toInterfaceOrientation;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusBarOrientationDidChange" object:self];
    }
}

- (id<NBMRenderer>)rendererForStream:(RTCMediaStream *)stream
{
    NSParameterAssert(stream);
    
    id<NBMRenderer> renderer = nil;
    RTCVideoTrack *videoTrack = [stream.videoTracks firstObject];
    NBMRendererType rendererType = self.mediaConfiguration.rendererType;
    
    if (rendererType == NBMRendererTypeOpenGLES) {
        renderer = [[NBMEAGLRenderer alloc] initWithDelegate:self];
    }
    
    renderer.videoTrack = videoTrack;
    
    return renderer;
}

- (void)removeRendererForStream:(RTCMediaStream *)stream
{
    // When checking for an RTCVideoTrack use indexOfObjectIdenticalTo: instead of containsObject:
    // RTCVideoTrack doesn't implement hash or isEqual: which caused false positives.
    
    id <NBMRenderer> rendererToRemove = nil;
    
    NSMutableArray *allRenderers = [NSMutableArray arrayWithArray:self.remoteRenderers];
    if (self.localRenderer) {
        [allRenderers addObject:self.localRenderer];
    }
    
    for (id<NBMRenderer> remoteRenderer in allRenderers) {
        NSUInteger videoTrackIndex = [stream.videoTracks indexOfObjectIdenticalTo:remoteRenderer.videoTrack];
        if (videoTrackIndex != NSNotFound) {
            rendererToRemove = remoteRenderer;
            break;
        }
    }
    
    if (rendererToRemove) {
        [self hideAndRemoveRenderer:rendererToRemove];
    }
    else {
        DDLogWarn(@"No renderer to remove for stream: %@", stream);
    }
}

- (void)hideAndRemoveRenderer:(id<NBMRenderer>)renderer
{
    renderer.videoTrack = nil;
    
    if (renderer == self.localRenderer) {
        self.localRenderer = nil;
    }
    else {
        [self.remoteRenderers removeObject:renderer];
    }
}

- (void)showSpinnerForPeer:(NBMPeer *)peer {
    [self updatePeer:peer block:^(NBMPeerViewCell *cell) {
        [cell showSpinner];
    }];
}

- (void)hideSpinnerForPeer:(NBMPeer *)peer {
    [self updatePeer:peer block:^(NBMPeerViewCell *cell) {
        [cell hideSpinner];
    }];
}

- (void)showErrorAlert:(NSString *)message action:(void(^)())block {
    [self hideProgressHUD:NO];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (block) {
            block();
        }
    }];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showChatMessageAlert:(NSString *)message from:(NSString *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:sender message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:defaultAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (NSIndexPath *)indexPathOfPeer:(NBMPeer *)peer {
    NSUInteger idx = [self.allPeers indexOfObject:peer];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    
    return indexPath;
}

- (void)updatePeer:(NBMPeer *)peer block:(void(^)(NBMPeerViewCell* cell))block {
    NSIndexPath *indexPath = [self indexPathOfPeer:peer];
    NBMPeerViewCell *cell = (id)[self.peersCollectionView cellForItemAtIndexPath:indexPath];
    block(cell);
} 

#pragma mark - UICollectionViewDataSource

- (NSArray *)allPeers {
    NSMutableArray *allPeers = [NSMutableArray arrayWithArray:self.roomManager.remotePeers];
    [allPeers insertObject:self.room.localPeer atIndex:0];
    
    return [allPeers copy];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.allPeers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NBMPeerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPeerCollectionViewCellIdentifier
                                                                                 forIndexPath:indexPath];
    cell.delegate = self;
    
    NBMPeer *peer = self.allPeers[indexPath.row];
    id<NBMRenderer> renderer = [self.peerIdToRenderer objectForKey:peer.identifier];
    [cell setVideoView:renderer.rendererView];
    [cell setPeerName:peer.identifier];
    NBMPeer *localPeer = self.roomManager.localPeer;
    if (renderer && [peer isEqual:localPeer]) {
        [cell addSwitchCamerButton];
    }
    
    return cell;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Calling -performBatchUpdates:completion: will invalidate the layout and resize the cells with animation
    [self.peersCollectionView performBatchUpdates:nil completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect frame = [NBMPeersFlowLayout frameForWithNumberOfItems:self.allPeers.count
                                                              row:indexPath.row
                                                      contentSize:self.peersCollectionView.frame.size];
    return frame.size;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"connected"]) {
        BOOL connected = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (connected) {
            [self onConnection];
        } else {
            [self onDisconnection];
        }
    }
    
    if ([keyPath isEqualToString:@"joined"]) {
        BOOL joined = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (joined) {
            [self onRoomJoined];
        }
    }
}

- (void)onConnection {
    
}

- (void)onDisconnection {
    
}

- (void)onRoomJoined {
    [self showSuccessHUD:@"Room joined"];
}

#pragma mark - NBMPeerVideCellDelegate

- (void)cell:(NBMPeerViewCell *)peerViewCell pressedSwitchButton:(UIButton *)switchButton {
    NBMCameraPosition oldPosition = self.roomManager.cameraPosition;
    NBMCameraPosition newPosition = oldPosition == NBMCameraPositionBack ? NBMCameraPositionFront : NBMCameraPositionBack;
    
    //check availability
    CATransition *animation = [CATransition animation];
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    
    if (oldPosition == NBMCameraPositionFront) {
        
        animation.subtype = kCATransitionFromRight;
    }
    else if(oldPosition == NBMCameraPositionBack) {
        
        animation.subtype = kCATransitionFromLeft;
    }
    
    [peerViewCell.contentView.layer addAnimation:animation forKey:nil];
    [self.roomManager selectCameraPosition:newPosition];
}

#pragma mark - NBMRoomManagerDelegate

- (void)roomManager:(NBMRoomManager *)broker roomJoined:(NSError *)error {
    if (error) {
        [self showErrorAlert:error.description action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self.peersCollectionView reloadData];
    }
}

- (void)roomManager:(NBMRoomManager *)broker didAddLocalStream:(RTCMediaStream *)localStream {
    id<NBMRenderer> renderer = [self rendererForStream:localStream];
    self.localRenderer = renderer;
    [self.peerIdToRenderer setValue:renderer forKey:self.room.localPeer.identifier];
    
    [self updatePeer:self.room.localPeer block:^(NBMPeerViewCell *cell) {
        [cell setVideoView:self.localRenderer.rendererView];
        [cell addSwitchCamerButton];
        [self enableStreamButtons:YES];
    }];
}

- (void)roomManager:(NBMRoomManager *)broker didRemoveLocalStream:(RTCMediaStream *)localStream {
    [self.peerIdToRenderer removeObjectForKey:self.room.localPeer.identifier];
    [self hideAndRemoveRenderer:self.localRenderer];
    
    [self updatePeer:self.room.localPeer block:^(NBMPeerViewCell *cell) {
        [cell hideSpinner];
        [cell setVideoView:nil];
        [cell removeSwitchCameraButton];
        [self enableStreamButtons:NO];
    }];
}

- (void)roomManager:(NBMRoomManager *)broker didAddStream:(RTCMediaStream *)remoteStream ofPeer:(NBMPeer *)remotePeer {
    id<NBMRenderer> renderer = [self rendererForStream:remoteStream];
    [self.remoteRenderers addObject:renderer];
    [self.peerIdToRenderer setValue:renderer forKey:remotePeer.identifier];
    
    [self updatePeer:remotePeer block:^(NBMPeerViewCell *cell) {
        [cell setVideoView:renderer.rendererView];
        [cell showSpinner];
    }];
}

- (void)roomManager:(NBMRoomManager *)broker didRemoveStream:(RTCMediaStream *)remoteStream ofPeer:(NBMPeer *)remotePeer {
    [self.peerIdToRenderer removeObjectForKey:remotePeer.identifier];
    [self removeRendererForStream:remoteStream];
    
    [self updatePeer:remotePeer block:^(NBMPeerViewCell *cell) {
        [cell hideSpinner];
        [cell setVideoView:nil];
    }];
}

- (void)roomManager:(NBMRoomManager *)broker peerJoined:(NBMPeer *)peer {
    [self.peersCollectionView reloadData];
}

- (void)roomManager:(NBMRoomManager *)broker peerLeft:(NBMPeer *)peer {
    [self.peersCollectionView reloadData];
}

- (void)roomManager:(NBMRoomManager *)broker didFailWithError:(NSError *)error {
    [self showErrorAlert:error.localizedDescription action:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)roomManager:(NBMRoomManager *)broker messageReceived:(NSString *)message ofPeer:(NBMPeer *)peer {
    [self showChatMessageAlert:message from:peer.identifier];
}

- (void)roomManagerPeerStatusChanged:(NBMRoomManager *)broker {
    [self.peersCollectionView reloadData];
}

- (void)roomManager:(NBMRoomManager *)broker iceStatusChanged:(RTCIceConnectionState)state ofPeer:(NBMPeer *)peer {
    switch (state) {
        case RTCIceConnectionStateConnected:
        case RTCIceConnectionStateCompleted:
        case RTCIceConnectionStateClosed:
        case RTCIceConnectionStateFailed:
        {
            [self hideSpinnerForPeer:peer];
        }
            break;
            
        case RTCIceConnectionStateCount:
        case RTCIceConnectionStateChecking:
        case RTCIceConnectionStateNew:
        case RTCIceConnectionStateDisconnected:
        {
            [self showSpinnerForPeer:peer];
        }
            break;
    }
}

- (void)renderer:(id<NBMRenderer>)renderer streamDimensionsDidChange:(CGSize)dimensions {
    
}

- (void)rendererDidReceiveVideoData:(id<NBMRenderer>)renderer {
    
}

- (void)roomManager:(NBMRoomManager *)broker didAddDataChannel:(RTCDataChannel *)dataChannel {
    DDLogDebug(@"roomManager didAddDataChanngel %@", dataChannel.label);
}

- (void)dataChannel:(RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer {
    
}

- (void)dataChannel:(RTCDataChannel *)dataChannel didChangeBufferedAmount:(uint64_t)amount {
    
}
@end