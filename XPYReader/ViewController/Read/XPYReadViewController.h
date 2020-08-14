//
//  XPYReadViewController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseViewController.h"

#import "XPYChapterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYReadViewController : XPYBaseViewController

/// 当前章节
@property (nonatomic, strong, readonly) XPYChapterModel *chapterModel;
/// 当前章节序号(从0开始，XPYChapterModel中的index默认从1开始)
@property (nonatomic, assign, readonly) NSInteger chapterIndex;
/// 当前章节所有内容
@property (nonatomic, copy, readonly) NSAttributedString *chapterContent;
/// 当前章节分页
@property (nonatomic, copy, readonly) NSArray *pageRanges;
/// 当前页码
@property (nonatomic, assign, readonly) NSInteger page;
/// 当前页面内容
@property (nonatomic, copy, readonly) NSAttributedString *pageContent;

/// 设置当前页面内容
/// @param chapter 章节Model
/// @param chapterContent 当前章节所有内容
/// @param pageRanges 当前章节分页
/// @param page 当前页码
/// @param pageContent 当前页码内容
- (void)setupChapter:(XPYChapterModel *)chapter
      chapterContent:(NSAttributedString *)chapterContent
          pageRanges:(NSArray *)pageRanges
                page:(NSInteger)page
         pageContent:(NSAttributedString *)pageContent;

@end

NS_ASSUME_NONNULL_END
