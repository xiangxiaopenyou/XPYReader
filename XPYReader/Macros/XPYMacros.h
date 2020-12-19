//
//  XPYMacros.h
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/6/1.
//  Copyright © 2020 xiang. All rights reserved.
//  宏文件

#import "XPYEnums.h"
#import "XPYBlocks.h"
#import "XPYConstant.h"

/// KeyWindow
#define XPYKeyWindow  [UIApplication sharedApplication].delegate.window

/// 以375宽度屏幕为基准自适应
#define XPYScreenScaleConstant(aConstant) CGRectGetWidth([UIScreen mainScreen].bounds) / 375 * aConstant

/// 屏幕宽度
#define XPYScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

/// 屏幕高度
#define XPYScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

/// statusbar高度
#define XPYStatusBarHeight (XPYDeviceIsIphoneX ? 44.0f : 20.0f)

/// App Document文件夹路径
#define XPYDocumentDirectory NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject

/// 弱引用对象
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;

/// 强引用对象
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;

/// 阅读器文字区域Rect
#define XPYReadViewBounds CGRectMake(0, 0, XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing, XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)
/// 阅读器文字区域宽度
#define XPYReadViewWidth (XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing)
/// 阅读去文字区域高度
#define XPYReadViewHeight (XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)

#pragma mark - Font
#define XPYFontBold(x) [UIFont fontWithName:@"PingFangSC-Semibold" size:x]
#define XPYFontRegular(x) [UIFont fontWithName:@"PingFangSC-Regular" size:x]
#define XPYFontMedium(x) [UIFont fontWithName:@"PingFangSC-Medium" size:x]
#define XPYFontLight(x) [UIFont fontWithName:@"PingFangSC-Light" size:x]

static inline NSString * XPYFilePath(NSString *name) {
    if (!name) {
        return XPYDocumentDirectory;
    }
    NSString *path = [XPYDocumentDirectory stringByAppendingPathComponent:name];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

