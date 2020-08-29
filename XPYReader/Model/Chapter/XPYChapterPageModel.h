//
//  XPYChapterPageModel.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/18.
//  Copyright © 2020 xiang. All rights reserved.
//  章节分页数据模型，实时分页生成，不保存入数据库

#import "XPYBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYChapterPageModel : XPYBaseModel

/// 页面内容范围
@property (nonatomic, assign) NSRange pageRange;

/// 页面内容
@property (nonatomic, copy) NSAttributedString *pageContent;

/// 页面序号
@property (nonatomic, assign) NSInteger pageIndex;

/// 页面内容高度（上下翻页模式使用）
@property (nonatomic, assign) CGFloat contentHeight;

/// 页面头部额外高度
@property (nonatomic, assign) CGFloat extraHeaderHeight;

@end

NS_ASSUME_NONNULL_END
