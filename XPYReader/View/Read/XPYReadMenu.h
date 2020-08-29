//
//  XPYReadMenu.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/13.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol XPYReadMenuDelegate <NSObject>

/// 菜单显示/隐藏状态变化
- (void)readMenuHideStatusDidChange:(BOOL)isHide;

/// 退出阅读器
- (void)readMenuDidExitReader;

/// 切换翻阅模式
- (void)readMenuDidChangePageType;

/// 切换背景
- (void)readMenuDidChangeBackground;

/// 开启自动阅读
- (void)readMenuDidOpenAutoRead;

/// 关闭自动阅读
- (void)readMenuDidCloseAutoRead;

/// 切换自动阅读模式
/// @param mode 自动阅读模式
- (void)readMenuDidChangeAutoReadMode:(XPYAutoReadMode)mode;

@end

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadMenu : NSObject

@property (nonatomic, weak) id <XPYReadMenuDelegate> delegate;

/// 是否正在显示
@property (nonatomic, assign, getter=isShowing, readonly) BOOL showing;
/// 是否正在显示自动阅读设置
@property (nonatomic, assign, getter=isShowingAutoReadSetting, readonly) BOOL showingAutoReadSetting;

/// 唯一初始化方法
/// @param sourceView 需要展示Menu的视图，为空则设为KeyWindow
- (instancetype)initWithView:(UIView * _Nullable)sourceView;

/// 显示菜单
- (void)show;

/// 隐藏菜单
/// @param complete 动画完成回调（可增加额外操作）
- (void)hiddenWithComplete:(nullable void (^)(void))complete;

/// 更新背景选择栏选中背景
/// @param colorIndex 颜色编号
- (void)updateSelectedBackgroundWithColorIndex:(NSInteger)colorIndex;

/// 显示自动阅读设置
- (void)showAutoReadSetting;

/// 隐藏自动阅读设置
- (void)hideAutoReadSetting;

@end

NS_ASSUME_NONNULL_END
