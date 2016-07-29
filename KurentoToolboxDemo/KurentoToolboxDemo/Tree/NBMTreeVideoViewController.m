//
//  NBMTreeVideoViewController.m
//  KurentoToolboxDemo
//
//  Created by Marco Rossi on 25/02/16.
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMTreeVideoViewController.h"
#import "NBMTreeManager.h"
#import "NBMRenderer.h"

#import "MBProgressHUD.h"

#import <WebRTC/RTCMediaStream.h>

#import "DGActivityIndicatorView.h"
#import "Masonry.h"

@interface NBMTreeVideoViewController () <NBMTreeManagerDelegate, NBMRendererDelegate>

@property (nonatomic, strong) NBMTreeManager *treeManager;
@property (nonatomic, assign) BOOL isMaster;
@property (nonatomic, copy) NSString *treeId;

@property (nonatomic, strong) NBMMediaConfiguration *mediaConfiguration;

@property (nonatomic, strong) id<NBMRenderer>videoRenderer;
@property (nonatomic, weak) UIView *videoView;
@property (nonatomic, weak) UIView *spinnerView;

@property (nonatomic, assign) UIInterfaceOrientation lastInterfaceOrientation;

@end

@implementation NBMTreeVideoViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _mediaConfiguration = [NBMMediaConfiguration defaultConfiguration];
        _isMaster = NO;
    }
    
    return self;
}

- (void)dealloc {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    [self removeTreeManagerKVO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.treeManager = [[NBMTreeManager alloc] initWithTreeURL:self.treeURL delegate:self];
    [self addTreeManagerKVO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.lastInterfaceOrientation = self.interfaceOrientation;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSString *existingTreeId = self.treeManager.treeId;
    if (existingTreeId) {
        if (_isMaster) {
            [self.treeManager stopMasteringTree:existingTreeId completion:nil];
        } else {
            [self.treeManager stopViewingTree:existingTreeId completion:nil];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutRenderer];
}

- (void)layoutRenderer {
    CGRect bounds = self.view.bounds;
    self.videoRenderer.rendererView.frame = bounds;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self informObserversOfOrientation:toInterfaceOrientation];
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

#pragma mark - Public 

- (void)startMasteringTree:(NSString *)treeId {
    self.isMaster = YES;
    self.treeId = treeId;
    self.title = treeId;
    NSString *msg = [NSString stringWithFormat:@"Mastering \"%@\" tree", self.treeId];
    [self showProgressHUD:msg];
}

- (void)startViewingTree:(NSString *)treeId {
    self.isMaster = NO;
    self.treeId = treeId;
    self.title = treeId;
    NSString *msg = [NSString stringWithFormat:@"Viewing \"%@\" tree", self.treeId];
    [self showProgressHUD:msg];
}

#pragma mark - Private

- (void)addTreeManagerKVO {
    [self.treeManager addObserver:self forKeyPath:@"connected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)removeTreeManagerKVO {
    [self.treeManager removeObserver:self forKeyPath:@"connected"];
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
}

- (void)onConnection {
    if (self.isMaster) {
        [self.treeManager startMasteringTree:self.treeId completion:^(NSError *error) {
            if (error) {
                [self showErrorAlert:error.description action:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                [self showSuccessHUD:nil];
            }
        }];
    }
    else {
        [self.treeManager startViewingTree:self.treeId completion:^(NSError *error) {
            if (error) {
                [self showErrorAlert:error.description action:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                [self showSuccessHUD:nil];
            }
        }];
    }
}

- (void)onDisconnection {
    
}

- (void)showRenderer:(id<NBMRenderer>)renderer {
    CGAffineTransform transform = CGAffineTransformIdentity;
    [self showRenderer:self.videoRenderer withTransform:transform];
}

- (void)hideRenderer:(id<NBMRenderer>)renderer {
    self.videoView = nil;
    [self hideView:renderer.rendererView];
}

- (void)showRenderer:(id<NBMRenderer>)renderer withTransform:(CGAffineTransform)finalTransform
{
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];
    self.videoView = renderer.rendererView;
    [self showView:_videoView withTransform:CGAffineTransformIdentity];
}

- (void)showView:(UIView *)view withTransform:(CGAffineTransform)finalTransform {
    [self.view addSubview:view];
    view.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.01, 0.01), finalTransform);
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.transform = finalTransform;
    } completion:nil];
}

- (void)hideView:(UIView *)view {
    CGAffineTransform finalTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.01, 0.01), view.transform);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.transform = finalTransform;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
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

#pragma mark - Progress HUD

- (void)showProgressHUD:(NSString *)msg {
    [self hideProgressHUD:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    if (msg) {
        hud.labelText = msg;
    }
}

- (void)showSuccessHUD:(NSString *)string {
    [self hideProgressHUD:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [[UIImage imageNamed:@"success"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    if (string) {
        hud.labelText = string;
    }
    [hud hide:YES afterDelay:1.0f];
}

- (void)showErrorHUD:(NSString *)string {
    [self hideProgressHUD:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [[UIImage imageNamed:@"error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    if (string) {
        hud.labelText = string;
    }
    [hud hide:YES afterDelay:1.0f];
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

#pragma mark - Spinner

- (void)showSpinner {
    if (_spinnerView.superview) {
        return;
    }
    DGActivityIndicatorView *spinner = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScaleParty tintColor:[UIColor whiteColor]];
    self.spinnerView = spinner;
    [spinner startAnimating];
    
    [self.view addSubview:self.spinnerView];
}

#pragma mark - NBMTreeManager delegate

- (void)treeManager:(NBMTreeManager *)broker didAddLocalStream:(RTCMediaStream *)localStream {
    id<NBMRenderer> renderer = [self rendererForStream:localStream];
    self.videoRenderer = renderer;
    [self showRenderer:renderer];
}

- (void)treeManager:(NBMTreeManager *)broker didAddStream:(RTCMediaStream *)remoteStream {
    id<NBMRenderer> renderer = [self rendererForStream:remoteStream];
    self.videoRenderer = renderer;
    [self showRenderer:renderer];
}

- (void)treeManager:(NBMTreeManager *)broker didRemoveStream:(RTCMediaStream *)remoteStream {
    [self hideRenderer:self.videoRenderer];
    self.videoRenderer = nil;
}

- (void)treeManager:(NBMTreeManager *)broker iceStatusChanged:(RTCIceConnectionState)state {
    
}

- (void)treeManager:(NBMTreeManager *)broker didFailWithError:(NSError *)error {
    [self showErrorAlert:error.localizedDescription action:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - NBMRendererDelegate

- (void)renderer:(id<NBMRenderer>)renderer streamDimensionsDidChange:(CGSize)dimensions
{
    DDLogVerbose(@"Stream dimensions did change for %@: %@", renderer, NSStringFromCGSize(dimensions));
    [self.view setNeedsLayout];
}

- (void)rendererDidReceiveVideoData:(id<NBMRenderer>)renderer
{
    DDLogVerbose(@"Did receive video data for renderer: %@", renderer);
}

@end
