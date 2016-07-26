//
//  CASegmentedControl.m
//  CASegmentedControl
//
//  Created by Carter Chang on 7/25/16.
//  Copyright © 2016 caa. All rights reserved.
//

#import "CASegmentedControl.h"

@interface CASegmentedControl ()
@property (nonatomic) NSArray *strings;
@property (nonatomic) NSMutableArray *topLabels;
@property (nonatomic) NSMutableArray *labels;
@property (nonatomic) UIView *sliderView;
@property (nonatomic) UIView *backgroundView;
@end

@implementation CASegmentedControl
- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSException raise:@"CASegmentedControlInitException" format:@"use initWithStrings"];
    }
    return self;
}

- (instancetype)initWithStrings:(NSArray *)strings {
    self = [super init];
    if(self){
        self.strings = strings;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    // Default value
    self.cornerRadius = 6.0;
    self.padding = 1;
    self.animationTime = 0.2;
    self.backgroundColor = [UIColor greenColor];
    self.sliderColor = [UIColor yellowColor];
    self.sliderTextColor = [UIColor grayColor];
    self.sliderTextTopColor = [UIColor blueColor];
    self.clipsToBounds = YES;
    self.font = [UIFont systemFontOfSize:12];
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = self.backgroundColor;
    self.backgroundView.userInteractionEnabled = YES;
    [self addSubview:self.backgroundView];
    self.labels = [NSMutableArray array];
    
    for (int i = 0; i < [self.strings count]; i++) {
        NSString *string = self.strings[i];
        UILabel *label = [[UILabel alloc] init];
        label.tag = i;
        label.text = string;
        label.font = self.font;
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = self.sliderTextColor;
        [self.backgroundView addSubview:label];
        [self.labels addObject:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
    }
    
    
    self.sliderView = [[UIView alloc] init];
    self.sliderView.backgroundColor = self.sliderColor;
    self.sliderView.clipsToBounds = YES;
    [self addSubview:self.sliderView];
    self.topLabels = [NSMutableArray array];
    
    for (NSString *string in self.strings) {
        UILabel *label = [[UILabel alloc] init];
        label.text = string;
        label.font = self.font;
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = self.sliderTextTopColor;
        label.textAlignment = NSTextAlignmentCenter;
        [self.sliderView addSubview:label];
        [self.topLabels addObject:label];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = [self convertRect:self.frame fromView:self.superview];
    
    self.backgroundView.backgroundColor = self.backgroundColor;
    self.sliderView.backgroundColor = self.sliderColor;
    self.layer.cornerRadius = self.cornerRadius;
    self.backgroundView.layer.cornerRadius = self.cornerRadius;
    self.sliderView.layer.cornerRadius = self.cornerRadius;
    
    CGFloat sliderWidth = self.frame.size.width / [self.strings count];
    
    self.sliderView.frame = CGRectMake(sliderWidth * self.selectedIndex + self.padding, self.backgroundView.frame.origin.y + self.padding, sliderWidth - self.padding * 2, self.frame.size.height - self.padding * 2);
    
    for (int i = 0; i < [self.labels count]; i++) {
        UILabel *label = self.labels[i];
        label.frame = CGRectMake(i * sliderWidth, 0, sliderWidth, self.frame.size.height);
        label.textColor = self.sliderTextColor;
        label.font = self.font;
    }
    
    for (int j = 0; j < [self.topLabels count]; j++) {
        UILabel *label = self.topLabels[j];
        CGPoint topLabelPos = [self.sliderView convertPoint:CGPointMake(j * sliderWidth, 0) fromView:self.backgroundView];
        label.frame = CGRectMake(topLabelPos.x, - self.padding, sliderWidth, self.frame.size.height);
        label.textColor = self.sliderTextTopColor;
        label.font = self.font;
    }
}

- (void)selectToIndex:(NSUInteger)index withAnimation:(BOOL)isAnimation sender:(id)sender
{
    NSUInteger fromIndex = self.selectedIndex;
    
    if([self.delegate respondsToSelector:@selector(segmentedControl:willMoveTo:from:sender:)]) {
        [self.delegate segmentedControl:self willMoveTo:index from:fromIndex sender:sender];
    }
    
    _selectedIndex = index;
    
    if (isAnimation) {
        [UIView animateWithDuration:self.animationTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            CGFloat sliderWidth = self.frame.size.width / [self.strings count];
            CGRect oldFrame = self.sliderView.frame;
            CGRect newFrame = CGRectMake(sliderWidth * self.selectedIndex + self.padding, self.backgroundView.frame.origin.y + self.padding, sliderWidth - self.padding * 2, self.frame.size.height - self.padding * 2);
            CGRect offRect = CGRectMake(newFrame.origin.x - oldFrame.origin.x, newFrame.origin.y - oldFrame.origin.y, 0, 0);
            self.sliderView.frame = newFrame;
            for (UILabel *label in self.topLabels) {
                label.frame = CGRectMake(label.frame.origin.x - offRect.origin.x, label.frame.origin.y - offRect.origin.y, label.frame.size.width, label.frame.size.height);
            }
        } completion:^(BOOL finished) {
            if([self.delegate respondsToSelector:@selector(segmentedControl:didMoveTo:from:sender:)]) {
                [self.delegate segmentedControl:self didMoveTo:index from:fromIndex sender:sender];
            }
        }];
    } else {
        CGFloat sliderWidth = self.frame.size.width / [self.strings count];
        CGRect oldFrame = self.sliderView.frame;
        CGRect newFrame = CGRectMake(sliderWidth * self.selectedIndex + self.padding, self.backgroundView.frame.origin.y + self.padding, sliderWidth - self.padding * 2, self.frame.size.height - self.padding * 2);
        CGRect offRect = CGRectMake(newFrame.origin.x - oldFrame.origin.x, newFrame.origin.y - oldFrame.origin.y, 0, 0);
        self.sliderView.frame = newFrame;
        for (UILabel *label in self.topLabels) {
            label.frame = CGRectMake(label.frame.origin.x - offRect.origin.x, label.frame.origin.y - offRect.origin.y, label.frame.size.width, label.frame.size.height);
        }
        if([self.delegate respondsToSelector:@selector(segmentedControl:didMoveTo:from:sender:)]) {
            [self.delegate segmentedControl:self didMoveTo:index from:fromIndex sender:sender];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)rec {
    [self selectToIndex:rec.view.tag withAnimation:YES sender:self];
}

- (void)moveTo:(NSUInteger)index sender:(id)sender{
    [self selectToIndex:index withAnimation:YES sender:sender];
}

- (void)moveTo:(NSUInteger)index withAnimation:(BOOL)isAnimated sender:(id)sender {
    [self selectToIndex:index withAnimation:isAnimated sender:sender];
}

- (void)updateIndicatorWithProgress:(CGFloat)progress {
    CGFloat sliderWidth = self.frame.size.width / [self.strings count];
    CGRect curFrame = self.sliderView.frame;
    
    CGRect oldFrame = CGRectMake(sliderWidth * self.selectedIndex, curFrame.origin.y, curFrame.size.width, curFrame.size.height);
    
    CGRect newFrame = CGRectMake(oldFrame.origin.x + progress * sliderWidth + self.padding, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
    
    
    self.sliderView.frame = newFrame;
    
    CGRect offRect = CGRectMake(newFrame.origin.x - curFrame.origin.x, newFrame.origin.y - curFrame.origin.y, 0, 0);
    
    for (UILabel *label in self.topLabels) {
        label.frame = CGRectMake(label.frame.origin.x - offRect.origin.x, label.frame.origin.y - offRect.origin.y, label.frame.size.width, label.frame.size.height);
    }
}

@end
