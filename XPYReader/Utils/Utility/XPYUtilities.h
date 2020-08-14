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

@end

NS_ASSUME_NONNULL_END
