//
//  XPYAutoReadCoverView.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/27.
//  Copyright © 2020 xiang. All rights reserved.
//  自动阅读覆盖模式覆盖视图

#import <UIKit/UIKit.h>

@class XPYChapterModel, XPYChapterPageModel;

/// 覆盖视图最小高度
#define kXPYCoverViewMinHeight 5
/// 覆盖视图最大高度
#define kXPYCoverViewMaxHeight XPYReadViewHeight + 10

NS_ASSUME_NONNULL_BEGIN

@interface XPYAutoReadCoverView : UIView

/// 当前章节信息
@property (nonatomic, strong, readonly) XPYChapterModel *chapterModel;
/// 当前页信息
@property (nonatomic, strong, readonly) XPYChapterPageModel *pageModel;

/// 更新覆盖视图当前章节信息和页码
/// @param chapter 章节
/// @param pageModel 页码信息
- (void)updateCurrentChapter:(XPYChapterModel *)chapter pageModel:(XPYChapterPageModel *)pageModel;

@end

NS_ASSUME_NONNULL_END
