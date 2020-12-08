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
/// 最小字号等级
static NSInteger const XPYMinReadFontSize = 25;
/// 最大字号等级
static NSInteger const XPYMaxReadFontSize = 13;

#pragma mark - 阅读间距
/// 默认阅读间距等级
static NSInteger const XPYDefaultReadSpacingLevel = 2;
/// 最小阅读间距等级
static NSInteger const XPYMinReadSpacingLevel = 0;
/// 最大阅读间距等级
static NSInteger const XPYMaxReadSpacingLevel = 4;

#pragma mark - 自动阅读速度
/// 默认自动阅读速度
static NSInteger const XPYDefaultAutoReadSpeed = 5;
/// 最小自动阅读速度
static NSInteger const XPYMinAutoReadSpeed = 1;
/// 最大自动阅读速度
static NSInteger const XPYMaxAutoReadSpeed = 15;

#pragma mark - 阅读背景颜色，这里随便设置了六种
#define XPYReadBackgroundColor1 [UIColor whiteColor]
#define XPYReadBackgroundColor2 XPYColorFromHex(0xF33333)
#define XPYReadBackgroundColor3 [UIColor grayColor]
#define XPYReadBackgroundColor4 XPYColorFromHex(0xD1E1D1)
#define XPYReadBackgroundColor5 [UIColor lightGrayColor]
#define XPYReadBackgroundColor6 [UIColor blackColor]

#endif /* XPYReadConfigDefines_h */
