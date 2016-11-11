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
