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

#import "NBMTreeMainViewController.h"
#import "NBMTreeMainViewCell.h"
#import "NBMTreeVideoViewController.h"

static NSString *defaultWsTree = @"https://kurento.teamlife.it:8890/kurento-tree/websocket";
static  NSString* const kTreeURLString = @"TreeServerURL";

@interface NBMTreeMainViewController () <NBMTreeViewCellDelegate>



@end

@implementation NBMTreeMainViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NBMTreeMainViewCell *cell = (NBMTreeMainViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TreeMainCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        cell.treeTf.text = [self treeServerURLString];
        cell.treeTf.placeholder = defaultWsTree;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Defaults

- (NSString *)treeServerURLString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *treeURLString = [defaults objectForKey:kTreeURLString];
    if (!treeURLString) {
        treeURLString = defaultWsTree;
    }
    
    return treeURLString;
}

- (void)saveTreeServerURLString:(NSString *)urlString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:urlString forKey:kTreeURLString];
    [defaults synchronize];
}

#pragma mark -NBMTreeViewCell delegate

- (void)treeTextInputViewCell:(NBMTreeMainViewCell *)cell shouldMasterTree:(NSString *)treeId {
    NSString *treeURLString = cell.treeTf.text;
    [self saveTreeServerURLString:treeURLString];
    NSURL *treeURL = [NSURL URLWithString:treeURLString];
    //[self performSegueWithIdentifier:@"NBMRoomVideoViewController" sender:room];
    NBMTreeVideoViewController *treeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TreeVideoViewController"];
    treeVC.treeURL = treeURL;
    treeVC.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:treeVC animated:YES];
    [treeVC startMasteringTree:treeId];
}

- (void)treeTextInputViewCell:(NBMTreeMainViewCell *)cell shouldViewTree:(NSString *)treeId {
    NSString *treeURLString = cell.treeTf.text;
    [self saveTreeServerURLString:treeURLString];
    NSURL *treeURL = [NSURL URLWithString:treeURLString];
    //[self performSegueWithIdentifier:@"NBMRoomVideoViewController" sender:room];
    NBMTreeVideoViewController *treeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TreeVideoViewController"];
    treeVC.treeURL = treeURL;
    treeVC.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:treeVC animated:YES];
    [treeVC startViewingTree:treeId];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    NBMRoomVideoViewController *viewController = (NBMRoomVideoViewController *)[segue destinationViewController];
//    [viewController setRoom:_room];
}



@end