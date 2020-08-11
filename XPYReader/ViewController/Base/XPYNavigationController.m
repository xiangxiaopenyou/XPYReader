//
//  XPYNavigationController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/5.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYNavigationController.h"

@interface XPYNavigationController ()

@end

@implementation XPYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
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
@end
