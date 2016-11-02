//
//  NBMToolbar.m
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

#import "NBMToolbar.h"

@interface NBMToolbar ()

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *actions;

@end

@implementation NBMToolbar

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        self.buttons = [NSMutableArray array];
        self.actions = [NSMutableArray array];
        
//        [self setBackgroundImage:[[UIImage alloc] init]
//              forToolbarPosition:UIToolbarPositionAny
//                      barMetrics:UIBarMetricsDefault];
//        
//        [self setShadowImage:[[UIImage alloc] init]
//          forToolbarPosition:UIToolbarPositionAny];
        
        //self.backgroundColor = [UIColor colorWithWhite:100.0f/255.0f alpha:1.0f];
    }
    return self;
}

- (void)updateItems {
    
    NSMutableArray *items = [NSMutableArray array];
    
    UIBarButtonItem *fs =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    for (UIButton *button in self.buttons) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        item.enabled = button.enabled;
        
        [items addObjectsFromArray:self.items];
        [items addObject:fs];
        [items addObject:item];
    }
    
    [items addObject:fs];
    [self setItems:items.copy];
}

- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action {
    
    [button addTarget:self
               action:@selector(pressButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttons addObject:button];
    [self.actions addObject:[action copy]];
}

- (void)pressButton:(UIButton *)button {
    
    NSUInteger idx = [self.buttons indexOfObject:button];
    
    void(^action)(UIButton *sender) = self.actions[idx];
    action(button);
}

@end
