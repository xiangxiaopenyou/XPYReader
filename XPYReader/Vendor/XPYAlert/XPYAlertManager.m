//
//  XPYAlertManager.m
//  zhangDu
//
//  Created by zhangdu_imac on 2019/9/25.
//  Copyright © 2019 ZD. All rights reserved.
//

#import "XPYAlertManager.h"
#import "XPYAlertController.h"

@implementation XPYAlertManager

+ (void)showAlertWithTitle:(NSString *)titleString
                   message:(NSString *)messageString
                    cancel:(NSString *)cancelString
                   confirm:(NSString *)confirmString
              inController:(UIViewController *)controller
            confirmHandler:(void (^)(void))confirm
             cancelHandler:(void (^)(void))cancel {
    if (!cancelString && !confirmString) {
        return;
    }
    XPYAlertModel *alertModel = [[XPYAlertModel alloc] initWithTitle:titleString message:messageString style:UIAlertControllerStyleAlert];
    [XPYAlertController makeAlert:^(XPYAlertController * _Nonnull alert) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        if (cancelString) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (cancel) {
                    cancel();
                }
            }];
            UIColor *cancelColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1];
            if (@available(iOS 13.0, *)) {
                cancelColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                    if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                        return [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1];;
                    }
                    return [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1];;
                }];
            }
            [cancelAction setValue:cancelColor forKey:@"_titleTextColor"];
            [items addObject:cancelAction];
        }
        
        if (confirmString) {
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmString style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                if (confirm) {
                    confirm();
                }
            }];
            [items addObject:confirmAction];
        }
        alert.actionItems(items).showAlert(controller);
    } alertModel:alertModel];
}
+ (void)showActionSheetWithTitle:(NSString *)titleString
                         message:(NSString *)messageString
                          cancel:(NSString *)cancelString
                    inController:(UIViewController *)controller
                      sourceView:(UIView *)sourceView
                         actions:(NSArray<NSString *> *)actions
                   actionHandler:(void (^)(NSInteger))actionHandler {
    if (actions.count == 0) {
        return;
    }
    XPYAlertModel *alertModel = [[XPYAlertModel alloc] initWithTitle:titleString message:messageString style:UIAlertControllerStyleActionSheet];
    [XPYAlertController makeAlert:^(XPYAlertController * _Nonnull alert) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        if (cancelString) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [items addObject:cancelAction];
        }
        [actions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (actionHandler) {
                    actionHandler(idx);
                }
            }];
            [items addObject:alertAction];
        }];
        alert.actionItems(items).sourceView(sourceView).showAlert(controller);
    } alertModel:alertModel];
}
@end
