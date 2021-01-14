//
//  XPYReadMenuBackgroundBar.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/20.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadMenuBackgroundBarDelegate <NSObject>

/// 选中背景回调
/// @param colorIndex 颜色编号
- (void)backgroundBarDidSelectColorIndex:(NSInteger)colorIndex;

@end

@interface XPYReadMenuBackgroundBar : UIView

@property (nonatomic, weak) id <XPYReadMenuBackgroundBarDelegate> delegate;

/// 初始化方法
/// @param frame frame
/// @param colorIndex 当前选中颜色编号
- (instancetype)initWithFrame:(CGRect)frame selectedColorIndex:(NSInteger)colorIndex;

/// 更新按钮位置（横竖屏切换）
- (void)updateButtonsConstraints;

/// 更新选中背景
/// @param colorIndex 颜色编号
- (void)updateSelectedColorWithColorIndex:(NSInteger)colorIndex;

@end

NS_ASSUME_NONNULL_END
