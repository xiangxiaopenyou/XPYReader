//
//  XPYReadMenuAutoReadSettingBar.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/26.
//  Copyright © 2020 xiang. All rights reserved.
//  自动阅读设置

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadMenuAutoReadSettingBarDelegate <NSObject>

/// 点击退出自动翻页
- (void)autoReadSettingBarDidClickExit;
/// 切换模式
- (void)autoReadSettingBarDidChangeMode:(XPYAutoReadMode)mode;
/// 改变阅读速度
- (void)autoReadSettingBarDidChangeReadSpeed:(NSInteger)speed;

@end

@interface XPYReadMenuAutoReadSettingBar : UIView

@property (nonatomic, weak) id <XPYReadMenuAutoReadSettingBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
