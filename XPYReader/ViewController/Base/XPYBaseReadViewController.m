//
//  XPYBaseReadViewController.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/24.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseReadViewController.h"

@interface XPYBaseReadViewController ()

@end

@implementation XPYBaseReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
}

#pragma mark - Override methods
/// 默认不支持屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

@end
