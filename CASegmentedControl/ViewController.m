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

@interface ViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>
@property (nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *filterControllers;
@property (nonatomic, weak) UIScrollView *pageViewControllerScrollView;
@property (nonatomic, strong) CASegmentedControl *segmentedControl;
@property (nonatomic, assign) BOOL pageControlIsDragging;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.segmentedControl = [[CASegmentedControl alloc] initWithStrings:@[@"AAA", @"BBB"]];
    NSInteger margin = 100;
     self.segmentedControl.frame = CGRectMake(margin, 100, self.view.frame.size.width - margin * 2, 30);
    [self.view addSubview: self.segmentedControl];

    
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
}

// Help function
- (CGFloat)pageViewDraggingRatio:(UIScrollView *)scrollView
{
    /*         ->
     -----------------
     |   |███|   |   |   segment control
     -----------------
     /    \
     /      \
     -----------------
     |   pageView    |   One page dragging invoke segment move a seg width portion
     |               |   (this case is 0.25 to 0.5)
     -----------------
     ->
     */
    CGFloat segmentStartRatio = self.segmentedControl.selectedIndex * 1.0f / self.filterControllers.count;
    // pageView content offset start from scrollView.frame
    CGFloat draggingOffset = scrollView.contentOffset.x - CGRectGetWidth(scrollView.frame);
    CGFloat draggingRatio = draggingOffset / self.filterControllers.count / CGRectGetWidth(scrollView.frame);
    return segmentStartRatio + draggingRatio;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {

 NSLog(@"======willTransitionToViewControllers==================");
}
//
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
     self.pageControlIsDragging = NO;
//    if (completed) {
    UIViewController *currentVC = self.pageViewController.viewControllers[0];
    NSUInteger currentIndex = [self.filterControllers indexOfObject:currentVC];
    [self.segmentedControl animateToIndex: currentIndex];
//   }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   self.pageControlIsDragging = YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
//    NSLog(@"=======%f====================", scrollView.contentOffset.x);
//    NSLog(@"=======%f====================", ( scrollView.contentOffset.x/scrollView.frame.size.width)-1 );
    CGFloat progress = scrollView.contentOffset.x/scrollView.frame.size.width;
    

    
    if (self.pageControlIsDragging) {
         [self.segmentedControl updateIndicatorWithProgress:progress-1];
           NSLog(@"=======%f====================", progress-1);
    }
   
    

//    if (scrollView.contentOffset.x && fmod(scrollView.contentOffset.x, CGRectGetWidth(scrollView.frame))) {
//          CGFloat ratio = [self pageViewDraggingRatio:scrollView];
//        
//         NSLog(@"=======%f====================",ratio);
//        // Todo: segmentControl transition
//        //        [self.segmentControl updateIndicatorWithProgress:ratio];
//    }
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
    NSLog(@"===========pageIndex===%ld============", pageIndex);
    return pageIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   
//    if (!decelerate) {
//        self.pageControlIsDragging = NO;
//        [self.segmentedControl selectToIndex:[self centerPageIndex] withAnimation:YES];
//    }
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    self.pageControlIsDragging = NO;
//    UIViewController *currentVC = self.pageViewController.viewControllers[0];
//    NSUInteger currentIndex = [self.filterControllers indexOfObject:currentVC];
//    [self.segmentedControl animateToIndex: currentIndex];
//
//}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
// 
//}

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



@end
