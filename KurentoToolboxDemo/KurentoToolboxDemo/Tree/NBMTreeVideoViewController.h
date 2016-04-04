//
//  NBMTreeVideoViewController.h
//  KurentoToolboxDemo
//
//  Created by Marco Rossi on 25/02/16.
//  Copyright © 2016 Telecom Italia S.p.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NBMTreeVideoViewController : UIViewController

@property (nonatomic, strong) NSURL *treeURL;

- (void)startMasteringTree:(NSString *)treeId;
- (void)startViewingTree:(NSString *)treeId;

@end
