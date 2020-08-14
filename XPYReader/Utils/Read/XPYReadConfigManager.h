//
//  XPYReadConfigManager.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/7.
//  Copyright © 2020 xiang. All rights reserved.
//  阅读配置

#import "XPYBaseModel.h"

/// 阅读翻页模式
typedef NS_ENUM(NSInteger, XPYReadPageType) {
    XPYReadPageTypeCurl,        // 仿真
    XPYReadPageTypeScroll,      // 左右滑动
    XPYReadPageTypeNone,        // 无动画
    XPYReadPageTypeVertical,    // 上下翻页
};

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadConfigManager : XPYBaseModel

/// 行间距
@property (nonatomic, assign) CGFloat lineSpacing;
/// 段落间距
@property (nonatomic, assign) CGFloat paragraphSpacing;
/// 字号
@property (nonatomic, assign) NSInteger fontSize;
/// 文字颜色
@property (nonatomic, strong) UIColor *textColor;
/// 翻页模式
@property (nonatomic, assign) XPYReadPageType pageType;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
