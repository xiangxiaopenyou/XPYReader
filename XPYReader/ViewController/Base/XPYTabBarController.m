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

@interface XPYTabBarController ()

@end

@implementation XPYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XPYBookStackViewController *stackController = [[XPYBookStackViewController alloc] init];
    stackController.title = @"书架";
    XPYBookStoreViewController *storeController = [[XPYBookStoreViewController alloc] init];
    storeController.title = @"书城";
    
    XPYNavigationController *stackNavigation = [[XPYNavigationController alloc] initWithRootViewController:stackController];
    XPYNavigationController *storeNavigation = [[XPYNavigationController alloc] initWithRootViewController:storeController];
    self.viewControllers = @[stackNavigation, storeNavigation];
}

@end
