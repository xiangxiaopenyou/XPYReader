//
//  XPYReadViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseViewController.h"
#import "XPYReadView.h"
#import "XPYChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XPYReadViewControllerDelegate <NSObject>

/// 下一页
- (void)readViewControllerShowNextPage;
/// 上一页
- (void)readViewControllerShowLastPage;

@end

@interface XPYReadViewController : XPYBaseViewController

@property (nonatomic, weak) id <XPYReadViewControllerDelegate> delegate;

/// 当前章节
@property (nonatomic, strong, readonly) XPYChapterModel *chapterModel;
/// 当前页码
@property (nonatomic, assign, readonly) NSInteger page;
/// 当前页面内容
@property (nonatomic, copy, readonly) NSAttributedString *pageContent;

/// 设置当前页面内容
/// @param chapter 章节Model
/// @param page 当前页码
/// @param pageContent 当前页码内容
- (void)setupChapter:(XPYChapterModel *)chapter
                page:(NSInteger)page
         pageContent:(NSAttributedString *)pageContent;

@end

NS_ASSUME_NONNULL_END
