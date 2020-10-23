//
//  XPYTransitionManager.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/10/16.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYTransitionManager.h"

#import "XPYOpenBookAnimation.h"
#import "XPYCloseBookAnimation.h"

#import "XPYReaderManagerController.h"
#import "XPYBookStackViewController.h"

@interface XPYTransitionManager ()

@end

@implementation XPYTransitionManager

+ (instancetype)shareManager {
    static XPYTransitionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XPYTransitionManager alloc] init];
    });
    return instance;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush && [toVC isMemberOfClass:[XPYReaderManagerController class]] && [fromVC isMemberOfClass:[XPYBookStackViewController class]] && self.pushView) {
        XPYOpenBookAnimation *open = [XPYOpenBookAnimation animationWithCoverView:self.pushView];
        // pushView设为nil
        self.pushView = nil;
        return open;
    } else if (operation == UINavigationControllerOperationPop && [toVC isMemberOfClass:[XPYBookStackViewController class]] && [fromVC isMemberOfClass:[XPYReaderManagerController class]] && self.popView) {
        XPYCloseBookAnimation *close = [XPYCloseBookAnimation animationWithCoverView:self.popView];
        // popView设为nil
        self.popView = nil;
        return close;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return nil;
}

@end
