//
//  XPYReadMenuBottomBar.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/19.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPYBookModel;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadMenuBottomBarDelegate <NSObject>

/// 点击背景模式
- (void)bottomBarDidClickBackground;
/// 点击章节目录
- (void)bottomBarDidClickCatalog;
/// 点击翻页模式
- (void)bottomBarDidClickPageType;
/// 点击设置
- (void)bottomBarDidClickSetting;
/// 下一章
- (void)bottomBarDidClickNextChapter;
/// 上一章
- (void)bottomBarDidClickLastChapter;
/// 滑动页码
- (void)bottomBarDidChangePage:(NSInteger)progress;
/// 滑动结束更新页码进度
- (void)bottomBarDidChangePageProgress:(NSInteger)progress;

@end

@interface XPYReadMenuBottomBar : UIView

@property (nonatomic, weak) id <XPYReadMenuBottomBarDelegate> delegate;

- (void)updatePageProgressWithBook:(XPYBookModel *)book;

@end

NS_ASSUME_NONNULL_END
