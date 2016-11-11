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

@protocol NBMRoomLoginViewCellDelegate;

@interface NBMRoomLoginViewCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *serverTf;
@property (strong, nonatomic) IBOutlet UIView *serverTfBorder;
@property (strong, nonatomic) IBOutlet UILabel *serverErrorLbl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *serverErrorLblHConstraint;

@property (strong, nonatomic) IBOutlet UITextField *roomTf;
@property (strong, nonatomic) IBOutlet UIView *roomTfBorder;
@property (strong, nonatomic) IBOutlet UILabel *roomErrorLbl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *roomErrorLblHConstraint;

@property (strong, nonatomic) IBOutlet UITextField *userTf;
@property (strong, nonatomic) IBOutlet UIView *userTfBorder;
@property (strong, nonatomic) IBOutlet UILabel *userErrorLbl;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userErrorLblHConstraint;

@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (nonatomic, weak) id <NBMRoomLoginViewCellDelegate> delegate;

@end

@protocol NBMRoomLoginViewCellDelegate<NSObject>
@optional
- (void)roomTextInputViewCell:(NBMRoomLoginViewCell *)cell shouldJoinRoom:(NSString *)roomName username:(NSString *)username;
@end


