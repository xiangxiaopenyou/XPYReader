//
//  XPYConstant.h
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/1.
//  Copyright © 2020 xiang. All rights reserved.
//  常量

#import <UIKit/UIKit.h>
/// 是否第一次安装Key
FOUNDATION_EXTERN NSString * const XPYIsFirstInstallKey;
/// 用户信息保存Key
FOUNDATION_EXTERN NSString * const XPYUserCacheKey;
/// 阅读配置保存Key
FOUNDATION_EXTERN NSString * const XPYReadConfigKey;

#pragma mark - Notification name
/// 登录状态变化通知
FOUNDATION_EXTERN NSString * const XPYLoginStatusDidChangeNotification;
/// 书架书籍变化通知
FOUNDATION_EXTERN NSString * const XPYBookStackDidChangeNotification;

#pragma mark - Tags
/// 阅读器主视图长按手势tag
FOUNDATION_EXTERN const NSUInteger XPYReadViewLongPressTag;
/// 阅读器主视图单击手势tag
FOUNDATION_EXTERN const NSUInteger XPYReadViewSingleTapTag;


