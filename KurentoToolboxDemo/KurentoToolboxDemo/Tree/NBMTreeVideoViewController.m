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

#import "RTCMediaStream.h"

@interface NBMTreeVideoViewController () <NBMTreeManagerDelegate, NBMRendererDelegate>

@property (nonatomic, strong) NBMTreeManager *treeManager;
@property (nonatomic, assign) BOOL isMaster;
@property (nonatomic, copy) NSString *treeId;
@property (nonatomic, strong) NBMMediaConfiguration *mediaConfiguration;
@property (nonatomic, strong) id<NBMRenderer>videoRenderer;

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
}

- (void)startViewingTree:(NSString *)treeId {
    self.isMaster = NO;
    self.treeId = treeId;
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
            
        }];
    } else {
        [self.treeManager startViewingTree:self.treeId completion:^(NSError *error) {
            
        }];
    }
}

- (void)onDisconnection {
    
}

- (void)showRenderer:(id<NBMRenderer>)renderer withTransform:(CGAffineTransform)finalTransform
{
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    UIView *theView = renderer.rendererView;
    [self.view addSubview:theView];
    
    theView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.01, 0.01), finalTransform);
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        theView.transform = finalTransform;
    } completion:nil];
}

- (void)hideRenderer:(id<NBMRenderer>)renderer {
    UIView *theView = renderer.rendererView;
    CGAffineTransform finalTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.01, 0.01), theView.transform);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        theView.transform = finalTransform;
    } completion:^(BOOL finished) {
        [theView removeFromSuperview];
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

- (void)showErrorAlert:(NSString *)message action:(void(^)())block {
//    [self hideProgressHUD:NO];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (block) {
            block();
        }
    }];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - NBMTreeManager delegate

- (void)treeManager:(NBMTreeManager *)broker didAddStream:(RTCMediaStream *)stream {
    id<NBMRenderer> renderer = [self rendererForStream:stream];
    self.videoRenderer = renderer;
    CGAffineTransform mirrorXTransform = CGAffineTransformMakeScale(-1.0, 1.0);
    [self showRenderer:self.videoRenderer withTransform:mirrorXTransform];
}

- (void)treeManager:(NBMTreeManager *)broker didRemoveStream:(RTCMediaStream *)stream {
    [self hideRenderer:self.videoRenderer];
    self.videoRenderer = nil;
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
