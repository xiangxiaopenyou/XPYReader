//
//  XPYUtilities.m
//  XPYToolsAndCategories
//
//  Created by zhangdu_imac on 2019/9/30.
//  Copyright © 2019 xpy. All rights reserved.
//

#import "XPYUtilities.h"
#import "XPYViewControllerHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation XPYUtilities

+ (BOOL)isIphoneX {
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    if (@available(iOS 11.0, *)) {
        CGFloat bottomInsets = keyWindow.safeAreaInsets.bottom;
        if (bottomInsets > 0) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isDarkUserInterfaceStyle {
    if (@available(iOS 12.0, *)) {
        if ([XPYViewControllerHelper currentViewController].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return YES;
        }
    }
    return NO;
}

+ (void)changeInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = (int)orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        
        /** 下面两行代码是为了当前导航栏或底部栏旋转至设备方向*/
        [UINavigationController attemptRotationToDeviceOrientation];
        [UITabBarController attemptRotationToDeviceOrientation];
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    //删除前缀字符
    if ([hexString hasPrefix:@"0X"] || [hexString hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    //判断字符串是否符合长度规范
    if (hexString.length != 6) {
        return [UIColor clearColor];
    }
    
    //截取色值字符
    NSRange range = NSMakeRange(0, 2);
    NSString *redString = [hexString substringWithRange:range];
    range.location = 2;
    NSString *greenString = [hexString substringWithRange:range];
    range.location = 4;
    NSString *blueString = [hexString substringWithRange:range];
    
    //转换成色值
    unsigned int red;
    unsigned int green;
    unsigned int blue;
    [[NSScanner scannerWithString:redString] scanHexInt:&red];
    [[NSScanner scannerWithString:greenString] scanHexInt:&green];
    [[NSScanner scannerWithString:blueString] scanHexInt:&blue];
    UIColor *resultColor = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
    return resultColor;
}

+ (CGFloat)textHeightWithText:(NSString *)text width:(CGFloat)width font:(UIFont *)font spacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentJustified;
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    if (lineSpacing > 0) {
        paraStyle.lineSpacing = lineSpacing;
    }
    CGSize contentSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:@{NSFontAttributeName : font, NSParagraphStyleAttributeName : paraStyle}
                                            context:nil].size;
    return ceilf(contentSize.height);
}

+ (BOOL)isEmptyObject:(id)object {
    if (!object || [object isEqual:@""] || [object isEqual:[NSNull null]] || [object isMemberOfClass:[NSNull class]]) {
        return YES;
    }
    return NO;
}

+ (NSString *)md5StringWithString:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (CGFloat)readViewLeftSpacing {
    // 当iPhoneX 处于横屏模式时返回54 其他情况返回20
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || !XPYDeviceIsIphoneX) {
        return 20;
    }
    return 54;
}

+ (CGFloat)readViewRightSpacing {
    // 当iPhoneX 处于横屏模式时返回54 其他情况返回20
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || !XPYDeviceIsIphoneX) {
        return 20;
    }
    return 54;
}

+ (CGFloat)readViewTopSpacing {
    return XPYStatusBarHeight + 25;
}

+ (CGFloat)readViewBottomSpacing {
    return 40 + (XPYDeviceIsIphoneX ? 24.0f : 0);
}
@end
