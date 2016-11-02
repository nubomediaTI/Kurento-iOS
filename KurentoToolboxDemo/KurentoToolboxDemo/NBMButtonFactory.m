//
//  NBMButtonFactory.m
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

#import "NBMButtonFactory.h"
#import "NBMButton.h"

const CGRect kDefRect = {0, 0, 44, 44};
const CGRect kDefDeclineRect = {0, 0, 96, 38};
const CGRect kDefCircleDeclineRect = {0, 0, 44, 44};

#define kDefBackgroundColor [UIColor colorWithRed:0.8118 green:0.8118 blue:0.8118 alpha:1.0]
#define kDefSelectedColor [UIColor colorWithRed:0.3843 green:0.3843 blue:0.3843 alpha:1.0]
#define kDefDeclineColor [UIColor colorWithRed:0.8118 green:0.0 blue:0.0784 alpha:1.0]
#define kDefAnswerColor [UIColor colorWithRed:0.1434 green:0.7587 blue:0.1851 alpha:1.0]


@implementation NBMButtonFactory

+ (NBMButton *)buttonWithFrame:(CGRect)frame
              backgroundColor:(UIColor *)backgroundColor
                selectedColor:(UIColor *)selectedColor  {
    
    NBMButton *button = [[NBMButton alloc] initWithFrame:frame];
    button.backgroundColor = backgroundColor;
    button.selectedColor = selectedColor;
    
    return button;
}

+ (UIImageView *)iconViewWithNormalImage:(NSString *)normalImage
                           selectedImage:(NSString *)selectedImage {
    
    UIImage *icon = [UIImage imageNamed:normalImage];
    UIImage *selectedIcon = [UIImage imageNamed:selectedImage];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon
                                              highlightedImage:selectedIcon];
    
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    return iconView;
}

+ (NBMButton *)videoEnable {
    
    NBMButton *button = [self buttonWithFrame:kDefRect
                             backgroundColor:kDefBackgroundColor
                               selectedColor:kDefSelectedColor];
    button.pushed = YES;
    
    button.iconView = [self iconViewWithNormalImage:@"ic_videocam_48pt"
                                      selectedImage:@"ic_videocam_off_white_48pt"];
    return button;
}

+ (NBMButton *)auidoEnable {
    
    NBMButton *button = [self buttonWithFrame:kDefRect
                             backgroundColor:kDefBackgroundColor
                               selectedColor:kDefSelectedColor];
    
    button.pushed = YES;
    
    button.iconView = [self iconViewWithNormalImage:@"ic_mic_48pt"
                                      selectedImage:@"ic_mic_off_white_48pt"];
    return button;
}

+ (NBMButton *)buttonWithNormalText:(NSString *)normalText selectedText:(NSString *)selectedText; {
    NBMButton *button = [self buttonWithFrame:kDefDeclineRect
                              backgroundColor:kDefBackgroundColor
                                selectedColor:kDefSelectedColor];
    button.pushed = YES;
    
    button.textColor = [UIColor darkGrayColor];
    button.textColorHighlight = [UIColor whiteColor];
    
    [button setTitle:normalText forState:UIControlStateNormal];
    [button setTitle:selectedText forState:UIControlStateHighlighted];
    
    [button setTitleColor:button.textColor forState:UIControlStateNormal];
    [button setTitleColor:button.textColorHighlight forState:UIControlStateHighlighted];
    
    return button;
}

@end
