//
//  XPYViewControllerHelper.m
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/10.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYViewControllerHelper.h"

@implementation XPYViewControllerHelper

+ (UIViewController *)currentViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window ? [UIApplication sharedApplication].delegate.window : [UIApplication sharedApplication].windows.lastObject;
    UIViewController *controller = window.rootViewController;
    return [self topViewController:controller];
}

+ (UIViewController *)topViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)controller selectedViewController]];
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)controller topViewController]];
    }
    if (controller.presentedViewController) {
        return [self topViewController:controller.presentedViewController];
    }
    if (controller.childViewControllers.count > 0) {
        return [self topViewController:controller.childViewControllers.lastObject];
    }
    return controller;
}

@end
