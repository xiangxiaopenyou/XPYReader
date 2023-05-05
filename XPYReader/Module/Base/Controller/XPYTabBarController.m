//
//  XPYTabBarController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/3.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYTabBarController.h"
#import "XPYNavigationController.h"
#import "XPYBookStackViewController.h"
#import "XPYBookStoreViewController.h"
#import "XPYMineViewController.h"

@interface XPYTabBarController ()

@end

@implementation XPYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XPYBookStackViewController *stackController = [[XPYBookStackViewController alloc] init];
    stackController.title = @"书架";
    XPYBookStoreViewController *storeController = [[XPYBookStoreViewController alloc] init];
    storeController.title = @"书城";
    XPYMineViewController *mineController = [[XPYMineViewController alloc] init];
    mineController.title = @"我的";

    XPYNavigationController *stackNavigation = [[XPYNavigationController alloc] initWithRootViewController:stackController];
    XPYNavigationController *storeNavigation = [[XPYNavigationController alloc] initWithRootViewController:storeController];
    XPYNavigationController *mineNavigation = [[XPYNavigationController alloc] initWithRootViewController:mineController];
    self.viewControllers = @[stackNavigation, storeNavigation, mineNavigation];
}

#pragma mark - Ovveride methods
- (BOOL)shouldAutorotate {
    UIViewController *controller = self.viewControllers[self.selectedIndex];
    return controller.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *controller = self.viewControllers[self.selectedIndex];
    return controller.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *controller = self.viewControllers[self.selectedIndex];
    return controller.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *controller = self.viewControllers[self.selectedIndex];
    return controller.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden{
    UIViewController *controller = self.viewControllers[self.selectedIndex];
    return controller.prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    UIViewController *controller = self.viewControllers[self.selectedIndex];
    return controller.preferredStatusBarUpdateAnimation;
}

@end
