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

#import "NBMTreeMainViewCell.h"

#define kValidColor [UIColor colorWithRed:66.0f/255.0f green:133.0f/255.0f blue:244.0f/255.0f alpha:1.0f]
#define kDisabledColor [UIColor colorWithWhite:100.0f/255.0f alpha:1.0f]
#define kErrorColor [UIColor colorWithRed:244.0f/255.0f green:67.0f/255.0f blue:54.0f/255.0f alpha:1.0f]

#define kMasterColor [UIColor colorWithRed:19.0f/255.0f green:124.0f/255.0f blue:19.0f/255.0f alpha:1.0f]
#define kViewerColor kValidColor

@implementation NBMTreeMainViewCell

- (void)awakeFromNib {
    [self.treeTf setDelegate:self];
    [self.treeTf becomeFirstResponder];
    [self.treeErrorLblHConstraint setConstant:0.0f];
    
    [self.treeIdTf setDelegate:self];
    [self.treeIdErrorLblHConstraint setConstant:0.0f];
    
    [self.masterButton setBackgroundColor:kDisabledColor];
    [self.masterButton setEnabled:NO];
    [self.masterButton.layer setCornerRadius:3.0f];
    
    [self.masterButton addTarget:self action:@selector(masterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewerButton setBackgroundColor:kDisabledColor];
    [self.viewerButton setEnabled:NO];
    [self.viewerButton.layer setCornerRadius:3.0f];
    
    [self.viewerButton addTarget:self action:@selector(viewerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
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
    
    NSURL *treeURL;
    if (textField == self.treeTf) {
        treeURL = [NSURL URLWithString:text];
    } else {
        treeURL = [NSURL URLWithString:self.treeTf.text];
    }
    BOOL isValidURL = [self validateURL:treeURL];
    
    BOOL isValidTree;
    if (textField == self.treeIdTf) {
        isValidTree = [self fieldIsValid:text];
    } else {
        isValidTree = [self fieldIsValid:self.treeIdTf.text];
    }

    
    BOOL isValidForm = isValidURL && isValidTree;
    
    [UIView animateWithDuration:0.3f animations:^{
        if (textField == self.treeTf) {
            [self updateServerTextfieldStatus:isValidURL];
        } else if (textField == self.treeIdTf) {
            [self updateTreeIdTextfieldStatus:isValidTree];
        }
        [self updateButtonsState:isValidForm];
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
        [self.treeErrorLblHConstraint setConstant:0.0f];
        [self.treeTfBorder setBackgroundColor:kValidColor];
    } else {
        [self.treeIdErrorLblHConstraint setConstant:40.0f];
        [self.treeTfBorder setBackgroundColor:kErrorColor];
    }
}

- (void)updateTreeIdTextfieldStatus:(BOOL)valid {
    if (valid) {
        [self.treeIdErrorLblHConstraint setConstant:0.0f];
        [self.treeIdTfBorder setBackgroundColor:kValidColor];
    } else {
        [self.treeIdErrorLblHConstraint setConstant:40.0f];
        [self.treeIdTfBorder setBackgroundColor:kErrorColor];
    }
}

- (void)updateButtonsState:(BOOL)valid {
    if (valid) {
        [self.masterButton setBackgroundColor:kMasterColor];
        [self.viewerButton setBackgroundColor:kViewerColor];
        [self.masterButton setEnabled:YES];
        [self.viewerButton setEnabled:YES];
    } else {
        [self.masterButton setBackgroundColor:kDisabledColor];
        [self.viewerButton setBackgroundColor:kDisabledColor];
        [self.masterButton setEnabled:NO];
        [self.viewerButton setEnabled:NO];
    }
}

- (void)masterButtonPressed {
    [self.contentView endEditing:YES];
    [self.delegate treeTextInputViewCell:self shouldMasterTree:self.treeIdTf.text];
}

- (void)viewerButtonPressed {
    [self.contentView endEditing:YES];
    [self.delegate treeTextInputViewCell:self shouldViewTree:self.treeIdTf.text];
}

- (BOOL)validateURL:(NSURL *)url {
    if (url && [url scheme] && [url host]) {
        return YES;
    }
    return NO;
}


@end
