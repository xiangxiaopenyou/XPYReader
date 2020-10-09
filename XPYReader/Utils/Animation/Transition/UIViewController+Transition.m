//
//  UIViewController+Transition.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/9/29.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "UIViewController+Transition.h"
#import "XPYOpenBookAnimation.h"
#import "XPYCloseBookAnimation.h"

#import "XPYBookStackViewController.h"
#import "XPYReaderManagerController.h"

@interface UIViewController () <UINavigationControllerDelegate>

@end

@implementation UIViewController (Transition)

#pragma mark - Navigation controller delegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush && [fromVC isMemberOfClass:[XPYBookStackViewController class]] && [toVC isMemberOfClass:[XPYReaderManagerController class]]) {
        // push
        toVC.bookCoverView = self.bookCoverView;
        return [XPYOpenBookAnimation animationWithBookCover:self.bookCoverView];
    }
    if (operation == UINavigationControllerOperationPop && [fromVC isMemberOfClass:[XPYReaderManagerController class]] && [toVC isMemberOfClass:[XPYBookStackViewController class]]) {
        // pop
        return [XPYCloseBookAnimation animationWithBookCover:self.bookCoverView];
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return nil;
}

#pragma mark - Getters
- (UIView *)bookCoverView {
    return objc_getAssociatedObject(self, @selector(bookCoverView));
}

#pragma mark - Setters
- (void)setBookCoverView:(UIView *)bookCoverView {
    objc_setAssociatedObject(self, @selector(bookCoverView), bookCoverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
