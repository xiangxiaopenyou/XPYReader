//
//  MBProgressHUD+XPYExtension.h
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/7/27.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (XPYExtension)

#pragma mark - 默认进度提示
/// 默认进度提示
/// @param tips 提示
+ (MBProgressHUD *)xpy_showActivityHUDWithTips:(NSString * _Nullable)tips;

/// 默认进度提示
/// @param tips 提示
/// @param view 指定View
+ (MBProgressHUD *)xpy_showActivityHUDWithTips:(NSString * _Nullable)tips addToView:(UIView *)view;

#pragma mark - 简单文字提示，自动隐藏
/// 简单文字提示
/// @param tips 提示
+ (MBProgressHUD *)xpy_showTips:(NSString *)tips;

/// 简单文字提示
/// @param tips 提示
/// @param view 指定View
+ (MBProgressHUD *)xpy_showTips:(NSString *)tips addToView:(UIView *_Nullable)view;

#pragma mark - 隐藏
+ (void)xpy_hideHUD;
+ (void)xpy_hideHUDForView:(UIView * _Nullable)view;

@end

NS_ASSUME_NONNULL_END
