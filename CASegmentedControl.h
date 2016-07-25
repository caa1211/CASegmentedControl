//
//  CASegmentedControl.h
//  CASegmentedControl
//
//  Created by Carter Chang on 7/25/16.
//  Copyright © 2016 caa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EMOSegmentedControlState) {
    EMOSegmentedControlStateBegin,
    EMOSegmentedControlStateDragging,
    EMOSegmentedControlStateEnd
};

@interface CASegmentedControl : UIControl
- (instancetype)initWithStrings:(NSArray *)strings;
- (void)updateIndicatorWithProgress:(CGFloat)progress;
- (void)animateToIndex:(NSUInteger)index;
@property (nonatomic) NSInteger selectedIndex;

@end
