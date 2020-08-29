//
//  XPYReadMenuBottomBar.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/19.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadMenuBottomBarDelegate <NSObject>

/// 点击背景
- (void)bottomBarDidClickBackground;
/// 点击翻页
- (void)bottomBarDidClickPageType;
/// 点击设置
- (void)bottomBarDidClickSetting;

@end

@interface XPYReadMenuBottomBar : UIView

@property (nonatomic, weak) id <XPYReadMenuBottomBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
