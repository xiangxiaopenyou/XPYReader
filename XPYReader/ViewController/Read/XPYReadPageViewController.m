//
//  XPYReadPageViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadPageViewController.h"

#import "XPYChapterModel.h"

@interface XPYReadPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation XPYReadPageViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"哈哈";
    
    [self addChildViewController:self.pageViewController];
}

#pragma mark - Page view controller data source
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    return nil;
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    return nil;
}

#pragma mark - Getters
- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)}];
        _pageViewController.doubleSided = YES;
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        _pageViewController.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}



@end
