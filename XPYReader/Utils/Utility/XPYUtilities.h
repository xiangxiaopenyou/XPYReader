//
//  XPYUtilities.h
//  XPYToolsAndCategories
//
//  Created by zhangdu_imac on 2019/9/30.
//  Copyright © 2019 xpy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYUtilities : NSObject

/// 是否iPhoneX系列机型
+ (BOOL)isIphoneX;

/// 当前设备是否深色模式
+ (BOOL)isDarkUserInterfaceStyle;

/// 强制旋转屏幕
/// @param orientation 方向
+ (void)changeInterfaceOrientation:(UIInterfaceOrientation)orientation;

/// 根据Hex字符串获取颜色
/// @param hexString 16进制字符串
/// @param alpha 透明度
+ (UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha;

/// 计算文字高度
/// @param text 文字内容
/// @param width 文字宽度
/// @param font 字体大小
/// @param lineSpacing 行间距
+ (CGFloat)textHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont *)font spacing:(CGFloat)lineSpacing;

/// 对象判空
/// @param object 对象
+ (BOOL)isEmptyObject:(id)object;

/// 字符串MD5加密
/// @param input 字符串
+ (NSString *)md5StringWithString:(NSString *)input;

/// 阅读内容左边距
+ (CGFloat)readViewLeftSpacing;

/// 阅读内容右边距
+ (CGFloat)readViewRightSpacing;

/// 阅读内容上边距
+ (CGFloat)readViewTopSpacing;

/// 阅读内容下边距
+ (CGFloat)readViewBottomSpacing;

@end

NS_ASSUME_NONNULL_END
