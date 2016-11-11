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
