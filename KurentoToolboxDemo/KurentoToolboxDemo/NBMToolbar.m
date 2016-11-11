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
