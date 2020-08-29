//
//  XPYUtilitiesDefine.h
//  XPYToolsAndCategories
//
//  Created by zhangdu_imac on 2019/9/30.
//  Copyright © 2019 xpy. All rights reserved.
//
#import "XPYUtilities.h"

/// 设备是否iPhoneX系列
#define XPYDeviceIsIphoneX [XPYUtilities isIphoneX]

/// 是否深色模式
#define XPYIsDarkUserInterfaceStyle [XPYUtilities isDarkUserInterfaceStyle]

/// 强制旋转屏幕
#define XPYChangeInterfaceOrientation(aOrientation) [XPYUtilities changeInterfaceOrientation:aOrientation]

/// 根据Hex值和透明度获取颜色
#define XPYColorFromHexWithAlpha(aHex, aAlpha) [UIColor colorWithRed:((float)((aHex & 0xFF0000) >> 16)) / 255.0 green:((float)((aHex & 0xFF00) >> 8)) / 255.0 blue:((float)(aHex & 0xFF)) / 255.0 alpha:aAlpha]

/// 根据Hex值获取颜色（透明度为1）
#define XPYColorFromHex(aHex) XPYColorFromHexWithAlpha(aHex, 1)

/// 根据Hex字符串和透明度获取颜色
#define XPYColorFromHexStringWithAlpha(aHexString, aAlpha) [XPYUtilities colorFromHexString:aHexString alpha:aAlpha]

/// 根据Hex字符串获取颜色（透明度为1）
#define XPYColorFromHexString(aHexString) XPYColorFromHexStringWithAlpha(aHexString, 1)

/// 获取文字高度
#define XPYTextHeight(aText, aWidth, aFont, aSpacing) [XPYUtilities textHeightWithText:aText width:aWidth font:aFont spacing:aSpacing]

/// 对象判空
#define XPYIsEmptyObject(aObject) [XPYUtilities isEmptyObject:aObject]

/// 字符串MD5加密
#define XPYMD5StringWithString(aString) [XPYUtilities md5StringWithString:aString]

#pragma mark - 阅读器
#define XPYReadViewLeftSpacing [XPYUtilities readViewLeftSpacing]
#define XPYReadViewRightSpacing [XPYUtilities readViewRightSpacing]
#define XPYReadViewTopSpacing [XPYUtilities readViewTopSpacing]
#define XPYReadViewBottomSpacing [XPYUtilities readViewBottomSpacing]

