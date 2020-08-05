//
//  MBProgressHUD+XPYExtension.m
//  XPYMoments
//
//  Created by zhangdu_imac on 2020/7/27.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "MBProgressHUD+XPYExtension.h"

@implementation MBProgressHUD (XPYExtension)

+ (MBProgressHUD *)xpy_showActivityHUDWithTips:(NSString *)tips {
    return [self xpy_showHUDWithTips:tips isAutoHide:NO addToView:nil];
}
+ (MBProgressHUD *)xpy_showActivityHUDWithTips:(NSString *)tips addToView:(UIView *)view {
    return [self xpy_showHUDWithTips:tips isAutoHide:NO addToView:view];
}

+ (MBProgressHUD *)xpy_showTips:(NSString *)tips {
    return [self xpy_showHUDWithTips:tips isAutoHide:YES addToView:nil];
}
+ (MBProgressHUD *)xpy_showTips:(NSString *)tips addToView:(UIView *)view {
    return [self xpy_showHUDWithTips:tips isAutoHide:YES addToView:view];
}

+ (instancetype)xpy_showHUDWithTips:(NSString *)tips isAutoHide:(BOOL)isAutoHide addToView:(UIView * _Nullable)view {
    UIView *sourceView = view ? view : ([UIApplication sharedApplication].delegate.window ? [UIApplication sharedApplication].delegate.window : [UIApplication sharedApplication].windows.lastObject);
    [self xpy_hideHUDForView:sourceView];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sourceView animated:YES];
    hud.mode = isAutoHide ? MBProgressHUDModeText : MBProgressHUDModeIndeterminate;
    hud.label.text = tips;
    if (isAutoHide) {
        [hud hideAnimated:YES afterDelay:2.f];
    }
    return hud;
}

+ (void)xpy_hideHUD {
    [self xpy_hideHUDForView:nil];
}
+ (void)xpy_hideHUDForView:(UIView *)view {
    UIView *sourceView = view ? view : ([UIApplication sharedApplication].delegate.window ? [UIApplication sharedApplication].delegate.window : [UIApplication sharedApplication].windows.lastObject);
    [self hideHUDForView:sourceView animated:YES];
}

@end
