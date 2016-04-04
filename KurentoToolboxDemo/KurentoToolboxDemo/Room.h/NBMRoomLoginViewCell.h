//
//  NBMRoomLoginViewCell.h
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


