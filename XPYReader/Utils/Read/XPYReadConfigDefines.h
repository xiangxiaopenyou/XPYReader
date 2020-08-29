//
//  XPYReadConfigDefines.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/24.
//  Copyright © 2020 xiang. All rights reserved.
//

#ifndef XPYReadConfigDefines_h
#define XPYReadConfigDefines_h

#import "XPYReadConfigManager.h"

#pragma mark - 阅读字号和字号等级
/// 默认阅读字号 19号字体
static NSInteger const XPYDefaultReadFontSize = 19;
/// 默认字号等级3对应19号默认字体
static NSInteger const XPYDefaultReadFontSizeLevel = 3;
/// 最小字号等级
static NSInteger const XPYMinReadFontSizeLevel = 1;
/// 最大字号等级
static NSInteger const XPYMaxReadFontSizeLevel = 8;

#pragma mark - 自动阅读速度
/// 默认自动阅读速度
static NSInteger const XPYDefaultAutoReadSpeed = 5;
/// 最小自动阅读速度
static NSInteger const XPYMinAutoReadSpeed = 1;
/// 最大自动阅读速度
static NSInteger const XPYMaxAutoReadSpeed = 15;

/// 默认听书速度
static NSInteger const XPYDefaultSpeechSpeed = 7;


#pragma mark - 阅读背景颜色
#define XPYReadBackgroundColor1 XPYColorFromHex(0xE9E9E9)
#define XPYReadBackgroundColor2 XPYColorFromHex(0xF3DDC0)
#define XPYReadBackgroundColor3 XPYColorFromHex(0x393436)
#define XPYReadBackgroundColor4 XPYColorFromHex(0xD1E7D0)
#define XPYReadBackgroundColor5 XPYColorFromHex(0x0F1F29)
#define XPYReadBackgroundColor6 XPYColorFromHex(0x080b10)

#endif /* XPYReadConfigDefines_h */
