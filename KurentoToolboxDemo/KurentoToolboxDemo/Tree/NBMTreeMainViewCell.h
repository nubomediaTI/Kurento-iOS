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

#import <UIKit/UIKit.h>

@protocol NBMTreeViewCellDelegate;

@interface NBMTreeMainViewCell : UITableViewCell<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *treeTf;
@property (strong, nonatomic) IBOutlet UIView *treeTfBorder;
@property (strong, nonatomic) IBOutlet UILabel *treeErrorLbl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *treeErrorLblHConstraint;

@property (strong, nonatomic) IBOutlet UITextField *treeIdTf;
@property (strong, nonatomic) IBOutlet UIView *treeIdTfBorder;
@property (strong, nonatomic) IBOutlet UILabel *treeIdErrorLbl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *treeIdErrorLblHConstraint;

@property (strong, nonatomic) IBOutlet UIButton *masterButton;
@property (strong, nonatomic) IBOutlet UIButton *viewerButton;
@property (nonatomic, weak) id <NBMTreeViewCellDelegate> delegate;

@end

@protocol NBMTreeViewCellDelegate<NSObject>
@optional
- (void)treeTextInputViewCell:(NBMTreeMainViewCell *)cell shouldMasterTree:(NSString *)treeId;
- (void)treeTextInputViewCell:(NBMTreeMainViewCell *)cell shouldViewTree:(NSString *)treeId;
@end
