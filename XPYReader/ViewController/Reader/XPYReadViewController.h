//
//  XPYReadViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseReadViewController.h"

@class XPYReadView;
@class XPYChapterPageModel, XPYChapterModel;

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadViewControllerDelegate <NSObject>

/// 下一页
- (void)readViewControllerShowNextPage;
/// 上一页
- (void)readViewControllerShowLastPage;

@end

@interface XPYReadViewController : XPYBaseReadViewController

@property (nonatomic, weak) id <XPYReadViewControllerDelegate> delegate;

/// 当前页数据
@property (nonatomic, strong, readonly) XPYChapterPageModel *pageModel;
/// 当前章节数据
@property (nonatomic, strong, readonly) XPYChapterModel *chapterModel;
/// 是否页面背面（仿真模式使用）
@property (nonatomic, assign, getter=isBackView, readonly) BOOL backView;

/// 设置当前页面内容
/// @param chapter 章节Model
/// @param pageModel 当前页面信息
/// @param isBackView 是否背面视图(用于仿真模式生成页面背面)
- (void)setupChapter:(XPYChapterModel *)chapter
           pageModel:(XPYChapterPageModel *)pageModel
          isBackView:(BOOL)isBackView;

@end

NS_ASSUME_NONNULL_END
