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

#import "NBMRoomLoginViewCell.h"

#define kValidColor [UIColor colorWithRed:66.0f/255.0f green:133.0f/255.0f blue:244.0f/255.0f alpha:1.0f]
#define kErrorColor [UIColor colorWithRed:244.0f/255.0f green:67.0f/255.0f blue:54.0f/255.0f alpha:1.0f]

@implementation NBMRoomLoginViewCell

- (void)awakeFromNib {
    [self.serverTf setDelegate:self];
    [self.serverTf becomeFirstResponder];
    [self.serverErrorLblHConstraint setConstant:0.0f];
    
    [self.roomTf setDelegate:self];
    [self.roomErrorLblHConstraint setConstant:0.0f];
    
    [self.userTf setDelegate:self];
    [self.userErrorLblHConstraint setConstant:0.0f];
    
    [self.joinButton setBackgroundColor:[UIColor colorWithWhite:100.0f/255.0f alpha:1.0f]];
    [self.joinButton setEnabled:NO];
    [self.joinButton.layer setCornerRadius:3.0f];
    
    [self.joinButton addTarget:self action:@selector(joinButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL isBackspace = [string isEqualToString:@""] && range.length == 1;
    NSString *text = [NSString stringWithFormat:@"%@%@", textField.text, string];
    if (isBackspace) {
        if (text.length > 1) {
            text = [text substringWithRange:NSMakeRange(0, text.length-1)];
        } else {
            text = string;
        }
    }
    
    NSURL *roomURL;
    if (textField == self.serverTf) {
        roomURL = [NSURL URLWithString:text];
    } else {
        roomURL = [NSURL URLWithString:self.serverTf.text];
    }
    BOOL isValidURL = [self validateURL:roomURL];
    
    BOOL isValidRoom;
    if (textField == self.roomTf) {
        isValidRoom = [self fieldIsValid:text];
    } else {
        isValidRoom = [self fieldIsValid:self.roomTf.text];
    }
    
    BOOL isValidUser;
    if (textField == self.userTf) {
        isValidUser = [self fieldIsValid:text];
    } else {
        isValidUser = [self fieldIsValid:self.userTf.text];
    }
    
    BOOL isValidForm = isValidURL && isValidRoom && isValidUser;
    
    [UIView animateWithDuration:0.3f animations:^{
        if (textField == self.serverTf) {
            [self updateServerTextfieldStatus:isValidURL];
        } else if (textField == self.roomTf) {
            [self updateRoomTextfieldStatus:isValidRoom];
        } else if (textField == self.userTf){
            [self updateUserTextfieldState:isValidUser];
        }
        [self updateJoinButtonState:isValidForm];
        [self layoutIfNeeded];
    }];
    
    return YES;
}

- (BOOL)fieldIsValid:(NSString *)field {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[field stringByTrimmingCharactersInSet: set] length] == 0) {
        return NO;
    }
    
    return YES;
}

- (void)updateServerTextfieldStatus:(BOOL)valid {
    if (valid) {
        [self.serverErrorLblHConstraint setConstant:0.0f];
        [self.serverTfBorder setBackgroundColor:kValidColor];
    } else {
        [self.serverErrorLblHConstraint setConstant:40.0f];
        [self.serverTfBorder setBackgroundColor:kErrorColor];
    }
}

- (void)updateRoomTextfieldStatus:(BOOL)valid {
    if (valid) {
        [self.roomErrorLblHConstraint setConstant:0.0f];
        [self.roomTfBorder setBackgroundColor:kValidColor];
    } else {
        [self.roomErrorLblHConstraint setConstant:40.0f];
        [self.roomTfBorder setBackgroundColor:kErrorColor];
    }
}

- (void)updateUserTextfieldState:(BOOL)valid {
    if (valid) {
        [self.userErrorLblHConstraint setConstant:0.0f];
        [self.userTfBorder setBackgroundColor:kValidColor];
    } else {
        [self.userErrorLblHConstraint setConstant:40.0f];
        [self.userTfBorder setBackgroundColor:kErrorColor];
    }
}

- (void)updateJoinButtonState:(BOOL)valid {
    if (valid) {
        [self.joinButton setBackgroundColor:kValidColor];
        [self.joinButton setEnabled:YES];
    } else {
        [self.joinButton setBackgroundColor:[UIColor colorWithWhite:100.0f/255.0f alpha:1.0f]];
        [self.joinButton setEnabled:NO];
    }
}

- (void)joinButtonPressed {
    NSString *room = self.roomTf.text;
    NSString *user = self.userTf.text;
    [self.contentView endEditing:YES];
    [self.delegate roomTextInputViewCell:self shouldJoinRoom:room username:user];
}

- (BOOL)validateURL:(NSURL *)url {
    if (url && [url scheme] && [url host]) {
        return YES;
    }
    return NO;
}

@end
