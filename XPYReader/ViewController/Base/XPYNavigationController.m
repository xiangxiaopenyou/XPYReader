//
//  XPYNavigationController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/5.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNavigationController.h"
#import "XPYBookStackViewController.h"
#import "XPYReaderManagerController.h"
#import "XPYOpenBookAnimation.h"

@interface XPYNavigationController () <UINavigationControllerDelegate>

@end

@implementation XPYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    self.delegate = self;
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

#pragma mark - Navigation controller delegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush && [fromVC isMemberOfClass:[XPYBookStackViewController class]] && [toVC isMemberOfClass:[XPYReaderManagerController class]]) {
        // 书架页push到阅读器
        XPYBookStackViewController *stackController = (XPYBookStackViewController *)fromVC;
        return [XPYOpenBookAnimation animationWithBookCover:stackController.selectedBookView];
    }
    if (operation == UINavigationControllerOperationPop && [fromVC isMemberOfClass:[XPYReaderManagerController class]] && [toVC isMemberOfClass:[XPYBookStackViewController class]]) {
        // 阅读器pop到书架页
        
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return nil;
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
