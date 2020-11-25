//
//  XPYReadMenu.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/13.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class XPYBookModel;

#define kXPYTopBarHeight ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? (44 + XPYStatusBarHeight) : 64)
#define kXPYBottomBarHeight (XPYDeviceIsIphoneX ? 144 : 110)

static CGFloat const kXPYBackgroundBarHeight = 100.f;
static CGFloat const kXPYPageTypeBarHeight = 79.f;
static CGFloat const kXPYReadMenuAnimationDuration = 0.2;

@protocol XPYReadMenuDelegate <NSObject>

/// 菜单显示/隐藏状态变化
- (void)readMenuHideStatusDidChange:(BOOL)isHide;

/// 退出阅读器
- (void)readMenuDidExitReader;

/// 选择上/下一章
/// @param isNext 是否下一章
- (void)readMenuDidChangeChapter:(BOOL)isNext;

/// 当前章节页码选择
/// @param progress 进度
- (void)readMenuDidChangePageProgress:(NSInteger)progress;

/// 打开书籍目录
- (void)readMenuDidOpenCatalog;

/// 切换翻页模式
- (void)readMenuDidChangePageType;

/// 切换背景
- (void)readMenuDidChangeBackground;

/// 字体大小
- (void)readMenuDidChangeFontSize;

/// 间距大小
- (void)readMenuDidChangeSpacing;

/// 开启自动阅读
- (void)readMenuDidOpenAutoRead;

/// 关闭自动阅读
- (void)readMenuDidCloseAutoRead;

/// 切换自动阅读模式
/// @param mode 自动阅读模式
- (void)readMenuDidChangeAutoReadMode:(XPYAutoReadMode)mode;

/// 切换自动阅读速度
/// @param speed 速度
- (void)readMenuDidChangeAutoReadSpeed:(NSInteger)speed;

/// 切换是否跟随系统横竖屏
- (void)readMenuDidChangeAllowLandscape:(BOOL)yesOrNo;

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
- (void)showWithBook:(XPYBookModel *)book;

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
