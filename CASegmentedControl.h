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

@class CASegmentedControl;
@protocol EMOSegmentedControlDelegate <NSObject>
@optional
- (void)segmentedControl:(CASegmentedControl *)segmentedControl willMoveTo:(NSUInteger)to from:(NSUInteger)from sender:sender;
- (void)segmentedControl:(CASegmentedControl *)segmentedControl didMoveTo:(NSUInteger)from from:(NSUInteger)from sender:sender;
@end


@interface CASegmentedControl : UIControl
- (instancetype)initWithStrings:(NSArray *)strings;
- (void)updateIndicatorWithProgress:(CGFloat)progress;
- (void)moveTo:(NSUInteger)index sender:(id)sender;
- (void)moveTo:(NSUInteger)index withAnimation:(BOOL)isAnimated sender:(id)sender;
@property (nonatomic, readonly) NSInteger selectedIndex;
@property (weak, nonatomic) id<EMOSegmentedControlDelegate>delegate;

// UI properties
@property (nonatomic) UIColor *sliderColor;
@property (nonatomic) UIColor *sliderTextTopColor;
@property (nonatomic) UIColor *sliderTextColor;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat animationTime;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) CGFloat padding;
@property (nonatomic) UIFont *font;
@end
