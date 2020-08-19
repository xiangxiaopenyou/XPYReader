//
//  XPYAlertManager.h
//  zhangDu
//
//  Created by zhangdu_imac on 2019/9/25.
//  Copyright © 2019 ZD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPYAlertManager : NSObject

/// Alert
/// @param titleString title
/// @param messageString message
/// @param cancelString 取消
/// @param confirmString 确定
/// @param controller 控制器
/// @param confirm 确定闭包
/// @param cancel 取消闭包
+ (void)showAlertWithTitle:(NSString * _Nullable)titleString
                   message:(NSString * _Nullable)messageString
                    cancel:(NSString * _Nullable)cancelString
                   confirm:(NSString * _Nullable)confirmString
              inController:(UIViewController *)controller
            confirmHandler:(void (^_Nullable)(void))confirm
             cancelHandler:(void (^_Nullable)(void))cancel;

/// ActionSheet
/// @param titleString title
/// @param messageString message
/// @param cancelString 取消
/// @param controller 控制器
/// @param sourceView 当设备为ipad时需要设置
/// @param actions 选项
/// @param actionHandler 选项闭包
+ (void)showActionSheetWithTitle:(NSString  * _Nullable)titleString
                         message:(NSString  * _Nullable)messageString
                          cancel:(NSString * _Nullable)cancelString
                    inController:(UIViewController *)controller
                      sourceView:(UIView *)sourceView
                         actions:(NSArray<NSString *> *)actions
                   actionHandler:(void (^)(NSInteger index))actionHandler;

@end

NS_ASSUME_NONNULL_END
