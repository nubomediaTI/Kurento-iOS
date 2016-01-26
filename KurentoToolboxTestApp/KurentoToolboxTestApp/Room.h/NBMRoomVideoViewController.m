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

@interface NBMRoomVideoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *peersCollectionView;
@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;

@property (nonatomic, strong) NBMRoomManager *roomManager;
@property (nonatomic, strong) NBMMediaConfiguration *mediaConfiguration;

@property (nonatomic, strong) id<NBMRenderer> localRenderer;
@property (nonatomic, strong) NSMutableArray *remoteRenderers;

@property (nonatomic, assign) UIInterfaceOrientation lastInterfaceOrientation;

@end

@implementation NBMRoomVideoViewController

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _remoteRenderers = [NSMutableArray array];
        _mediaConfiguration = [NBMMediaConfiguration defaultConfiguration];
    }
    return self;
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = @"Connecting...";
}

#pragma mark - Private

- (void)informObserversOfOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // Due to an odd implementation detail in RTCVideoCaptureIosObjC (rtc_video_capture_ios_objc.m),
    // we must inform the capturer of orientation changes by posting a 'StatusBarOrientationDidChange' notification.
    
    if (toInterfaceOrientation != self.lastInterfaceOrientation) {
        self.lastInterfaceOrientation = toInterfaceOrientation;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusBarOrientationDidChange" object:self];
    }
}

@end