//
//  ViewController.m
//  CASegmentedControl
//
//  Created by Carter Chang on 7/25/16.
//  Copyright © 2016 caa. All rights reserved.
//

#import "ViewController.h"
#import "CASegmentedControl.h"
#import "VC1.h"
#import "VC2.h"

@interface ViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate, EMOSegmentedControlDelegate>
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *filterControllers;
@property (nonatomic, weak) UIScrollView *pageViewControllerScrollView;
@property (nonatomic, strong) CASegmentedControl *segmentedControl;
@property (nonatomic, assign) BOOL pageControlIsDragging;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.segmentedControl = [[CASegmentedControl alloc] initWithStrings:@[@"VC1", @"VC2"]];
    NSInteger margin = 100;
     self.segmentedControl.frame = CGRectMake(margin, 100, self.view.frame.size.width - margin * 2, 30);
    [self.view addSubview: self.segmentedControl];
    self.segmentedControl.delegate = self;
    self.segmentedControl.font = [UIFont systemFontOfSize:22];
    self.segmentedControl.cornerRadius = 5;
    self.segmentedControl.sliderTextColor = [UIColor redColor];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageViewController.view.backgroundColor = [UIColor lightGrayColor];
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    self.pageViewController.view.exclusiveTouch = YES;
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Setup mask view for collection view
    CGRect pageViewFrame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    [self.pageViewController.view setFrame: pageViewFrame];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageViewControllerScrollView = (UIScrollView *)view;
            [(UIScrollView *)view setDelegate:self];
        }
    }
    
    [self.view addSubview:self.pageViewController.view];
    
    VC1 *vc1 = [[VC1 alloc] init];
    [vc1.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
    
    VC2 *vc2 = [[VC2 alloc] init];
    [vc2.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
    
    self.filterControllers = @[vc1, vc2];
    
    [self.pageViewController setViewControllers: @[vc1] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Default index setup
    [self.segmentedControl moveTo:0 withAnimation:NO sender:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (!scrollView.isDecelerating) {
        //for sync menuslider, use pageControlIsDragging instead of scrollView.isDragging
        self.pageControlIsDragging = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat progress = scrollView.contentOffset.x/scrollView.frame.size.width;

    if (self.pageControlIsDragging&& scrollView.contentOffset.x && fmod(scrollView.contentOffset.x, CGRectGetWidth(scrollView.frame))) {
         [self.segmentedControl updateIndicatorWithProgress:progress-1];
    }
}

- (NSUInteger)centerPageIndex
{
    __block NSUInteger pageIndex = [self.filterControllers indexOfObject:[self.pageViewController.viewControllers firstObject]];
    if (self.pageViewControllerScrollView.subviews.count <= 1) {
        return pageIndex;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.filterControllers enumerateObjectsUsingBlock:^(UIViewController  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // pageViewControllerScrollView has 3 subviews, subviews[1] represent center one
        if (obj.view.superview == weakSelf.pageViewControllerScrollView.subviews[1]) {
            pageIndex = idx;
            *stop = YES;
        }
    }];
    return pageIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.pageViewController.view.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageViewController.view.userInteractionEnabled = YES;
    self.pageControlIsDragging = NO;
    [self.segmentedControl moveTo:[self centerPageIndex] sender:self];
}

#pragma mark - UIPageViewControllerDataSource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger currentIndex = [self.filterControllers indexOfObject:viewController];
    if (currentIndex) {
        return self.filterControllers[currentIndex - 1];
    }
    return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger currentIndex = [self.filterControllers indexOfObject:viewController];
    if (currentIndex < self.filterControllers.count - 1) {
        return self.filterControllers[currentIndex + 1];
    }
    return nil;
}

#pragma mark - EMOSegmentedControlDelegate
- (void)segmentedControl:(CASegmentedControl *)segmentedControl willMoveTo:(NSUInteger)to from:(NSUInteger)from sender:sender{
    
    if (sender==self) {
        // if change segment index by scrollView didScroll, do not need to change pageViewController again
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = from < to ?  UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    __weak typeof(self) weakSelf = self;
    
    // reference: http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller
    [self.pageViewController setViewControllers:@[self.filterControllers[to]] direction:direction animated:YES completion:^(BOOL finished){
        if(finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pageViewController setViewControllers:@[weakSelf.filterControllers[to]] direction:direction animated:NO completion:nil];// bug fix for uipageview controller
            });
        }
    }];
}

- (void)segmentedControl:(CASegmentedControl *)segmentedControl didMoveTo:(NSUInteger)to from:(NSUInteger)from {
    

}

@end
