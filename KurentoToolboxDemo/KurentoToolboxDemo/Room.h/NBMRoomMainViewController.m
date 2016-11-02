//
//  NBMRoomMainViewController.m
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

#import "NBMRoomMainViewController.h"
#import "NBMRoomLoginViewCell.h"
#import "NBMRoomVideoViewController.h"

#import "MBProgressHUD.h"

//#error : Define WS Room URI (es. wss://localhost:8443/room)
static NSString *defaultWsRoom = @"https://kurento.teamlife.it:8443/room";
static  NSString* const kRoomURLString = @"RoomServerURL";

@interface NBMRoomMainViewController () <NBMRoomLoginViewCellDelegate>

@property (nonatomic, strong) NBMRoom *room;

@end

@implementation NBMRoomMainViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NBMRoomLoginViewCell *cell = (NBMRoomLoginViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RoomLoginCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        cell.serverTf.text = [self roomServerURLString];
        cell.serverTf.placeholder = defaultWsRoom;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Defaults

- (NSString *)roomServerURLString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *roomURLString = [defaults objectForKey:kRoomURLString];
    if (!roomURLString) {
        roomURLString = defaultWsRoom;
    }
    
    return roomURLString;
}

- (void)saveRoomServerURLString:(NSString *)urlString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:urlString forKey:kRoomURLString];
    [defaults synchronize];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NBMRoomVideoViewController *viewController = (NBMRoomVideoViewController *)[segue destinationViewController];
    [viewController setRoom:_room];
}

#pragma mark - ARTCRoomTextInputViewCellDelegate Methods

- (void)roomTextInputViewCell:(NBMRoomLoginViewCell *)cell shouldJoinRoom:(NSString *)room username:(NSString *)username {
    NSString *roomURLString = cell.serverTf.text;
    [self saveRoomServerURLString:roomURLString];
    NSURL *roomURL = [NSURL URLWithString:roomURLString];
    self.room = [[NBMRoom alloc] initWithUsername:username roomName:room roomURL:roomURL dataChannels:YES];
    //[self performSegueWithIdentifier:@"NBMRoomVideoViewController" sender:room];
    NBMRoomVideoViewController *videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RoomVideoViewController"];
    videoVC.room = _room;
    videoVC.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:videoVC animated:YES];
}

@end
