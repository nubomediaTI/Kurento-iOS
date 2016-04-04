//
//  NBMTreeMainViewController.m
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