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
@property (nonatomic) UIColor *sliderColor;
@property (nonatomic) UIColor *sliderTextTopColor;
@property (nonatomic) UIColor *sliderTextColor;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) NSInteger animationTime;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) CGFloat padding;
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
    self.animationTime = 300;
    self.backgroundColor = [UIColor greenColor];
    self.sliderColor = [UIColor yellowColor];
    self.sliderTextColor = [UIColor grayColor];
    self.sliderTextTopColor = [UIColor blueColor];
    self.clipsToBounds = YES;
    
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

    self.backgroundView.backgroundColor = self.backgroundColor;
    self.sliderView.backgroundColor = self.sliderColor;
    
    self.backgroundView.frame = [self convertRect:self.frame fromView:self.superview];
    
    self.layer.cornerRadius = self.cornerRadius;
    self.backgroundView.layer.cornerRadius = self.cornerRadius;
    self.sliderView.layer.cornerRadius = self.cornerRadius;
    
    CGFloat sliderWidth = self.frame.size.width / [self.strings count];
    
    self.sliderView.frame = CGRectMake(sliderWidth * self.selectedIndex + self.padding, self.backgroundView.frame.origin.y + self.padding, sliderWidth - self.padding * 2, self.frame.size.height - self.padding * 2);
    
    for (int i = 0; i < [self.labels count]; i++) {
        UILabel *label = self.labels[i];
        label.frame = CGRectMake(i * sliderWidth, 0, sliderWidth, self.frame.size.height);
        label.textColor = self.sliderTextColor;
    }
    
    for (int j = 0; j < [self.topLabels count]; j++) {
        UILabel *label = self.topLabels[j];
        CGPoint topLabelPos = [self.sliderView convertPoint:CGPointMake(j * sliderWidth, 0) fromView:self.backgroundView];
        label.frame = CGRectMake(topLabelPos.x, - self.padding, sliderWidth, self.frame.size.height);
        label.textColor = self.sliderTextTopColor;
    }
}

- (void)selectToIndex:(NSUInteger)selectedIndex withAnimation:(BOOL)isAnimation
{
    
//    if (self.willBePressedHandlerBlock) {
//        self.willBePressedHandlerBlock(selectedIndex);
//    }
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGFloat sliderWidth = self.frame.size.width / [self.strings count];
        CGRect oldFrame = self.sliderView.frame;
        CGRect newFrame = CGRectMake(sliderWidth * self.selectedIndex + self.padding, self.backgroundView.frame.origin.y + self.padding, sliderWidth - self.padding * 2, self.frame.size.height - self.padding * 2);
        CGRect offRect = CGRectMake(newFrame.origin.x - oldFrame.origin.x, newFrame.origin.y - oldFrame.origin.y, 0, 0);
        self.sliderView.frame = newFrame;
        for (UILabel *label in self.topLabels) {
            label.frame = CGRectMake(label.frame.origin.x - offRect.origin.x, label.frame.origin.y - offRect.origin.y, label.frame.size.width, label.frame.size.height);
        }
    } completion:^(BOOL finished) {
        
//        if (self.handlerBlock && callHandler) {
//            self.handlerBlock(selectedIndex);
//        }
    }];
}

- (void)handleTap:(UITapGestureRecognizer *)rec {
    self.selectedIndex = rec.view.tag;
    [self selectToIndex:self.selectedIndex withAnimation:YES];
}

- (void)animateToIndex:(NSUInteger)index {
    self.selectedIndex = index;
    [self selectToIndex:self.selectedIndex withAnimation:YES];
}

//- (void)updateIndicatorWithProgress:(CGFloat)progress state:(EMOSegmentedControlState)state{
//
//}

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


- (void)sliderPan:(UIPanGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateChanged) {
        CGRect oldFrame = self.sliderView.frame;
        
        CGFloat minPos = 0 + self.padding;
        CGFloat maxPos = self.frame.size.width - self.padding - self.sliderView.frame.size.width;
        
        CGPoint center = rec.view.center;
        CGPoint translation = [rec translationInView:rec.view];
        
        center = CGPointMake(center.x + translation.x, center.y);
        rec.view.center = center;
        [rec setTranslation:CGPointZero inView:rec.view];
        
        if (self.sliderView.frame.origin.x < minPos) {
            
            self.sliderView.frame = CGRectMake(minPos, self.sliderView.frame.origin.y, self.sliderView.frame.size.width, self.sliderView.frame.size.height);
            
        } else if (self.sliderView.frame.origin.x > maxPos) {
            
            self.sliderView.frame = CGRectMake(maxPos, self.sliderView.frame.origin.y, self.sliderView.frame.size.width, self.sliderView.frame.size.height);
        }
        
        CGRect newFrame = self.sliderView.frame;
        CGRect offRect = CGRectMake(newFrame.origin.x - oldFrame.origin.x, newFrame.origin.y - oldFrame.origin.y, 0, 0);
        
        for (UILabel *label in self.topLabels) {
            
            label.frame = CGRectMake(label.frame.origin.x - offRect.origin.x, label.frame.origin.y - offRect.origin.y, label.frame.size.width, label.frame.size.height);
        }
        
    } else if (rec.state == UIGestureRecognizerStateEnded || rec.state == UIGestureRecognizerStateCancelled || rec.state == UIGestureRecognizerStateFailed) {
        
        NSMutableArray *distances = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [self.strings count]; i++) {
            
            CGFloat possibleX = i * self.sliderView.frame.size.width;
            CGFloat distance = possibleX - self.sliderView.frame.origin.x;
            [distances addObject:@(fabs(distance))];
        }
        
        NSNumber *num = [distances valueForKeyPath:@"@min.doubleValue"];
        NSInteger index = [distances indexOfObject:num];
        
//        if (self.willBePressedHandlerBlock) {
//            self.willBePressedHandlerBlock(index);
//        }
        
        CGFloat sliderWidth = self.frame.size.width / [self.strings count];
        CGFloat desiredX = sliderWidth * index + self.padding;
        
        if (self.sliderView.frame.origin.x != desiredX) {
            
            CGRect evenOlderFrame = self.sliderView.frame;
            
            CGFloat distance = desiredX - self.sliderView.frame.origin.x;
            CGFloat time = fabs(distance / self.animationTime);
            
            [UIView animateWithDuration:time animations:^{
                
                self.sliderView.frame = CGRectMake(desiredX, self.sliderView.frame.origin.y, self.sliderView.frame.size.width, self.sliderView.frame.size.height);
                
                CGRect newFrame = self.sliderView.frame;
                
                CGRect offRect = CGRectMake(newFrame.origin.x - evenOlderFrame.origin.x, newFrame.origin.y - evenOlderFrame.origin.y, 0, 0);
                
                for (UILabel *label in self.topLabels) {
                    
                    label.frame = CGRectMake(label.frame.origin.x - offRect.origin.x, label.frame.origin.y - offRect.origin.y, label.frame.size.width, label.frame.size.height);
                }
            } completion:^(BOOL finished) {
                
                self.selectedIndex = index;
                
//                if (self.handlerBlock) {
//                    self.handlerBlock(index);
//                }
                
            }];
            
        } else {
            
            self.selectedIndex = index;
            
//            if (self.handlerBlock) {
//                self.handlerBlock(self.selectedIndex);
//            }
        }
    }
}


@end
