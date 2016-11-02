//
//  NBMTreeMainCell.m
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
