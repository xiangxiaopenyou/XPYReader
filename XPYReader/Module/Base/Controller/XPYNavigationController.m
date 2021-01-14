//
//  XPYNavigationController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/5.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNavigationController.h"

#import "XPYTransitionManager.h"

@interface XPYNavigationController ()

@end

@implementation XPYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置NavigationController代理，实现自定义转场动画
    self.delegate = [XPYTransitionManager shareManager];
    
    self.navigationBar.tintColor = XPYColorFromHex(0x333333);
}

/**
 如果push到第一个页面则设置hidesBottomBarWhenPushed = YES隐藏TabBar

 @param viewController push目标控制器
 @param animated YES
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSInteger count = self.childViewControllers.count;
    if (count == 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark - Override methods
- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.topViewController.supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden{
    return self.topViewController.prefersStatusBarHidden;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.topViewController.preferredStatusBarUpdateAnimation;
}

@end
