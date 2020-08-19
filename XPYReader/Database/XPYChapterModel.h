//
//  XPYChapterModel.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPYChapterModel : XPYBaseModel

@property (nonatomic, copy) NSString *chapterId;
@property (nonatomic, copy) NSString *bookId;
/// 章节编号(从1开始)
@property (nonatomic, assign) NSInteger chapterIndex;
/// 章节名称
@property (nonatomic, copy) NSString *chapterName;
/// 章节内容
@property (nonatomic, copy) NSString *content;
/// 章节字数
@property (nonatomic, assign) NSInteger charNum;
/// 0免费 1付费
@property (nonatomic, assign) BOOL needFee;
/// 价格
@property (nonatomic, assign) NSInteger price;

#pragma mark - 不保存进数据库
/// 当前章节分页
@property (nonatomic, copy) NSArray *pageRanges;
/// 包含文字属性的章节内容
@property (nonatomic, copy) NSAttributedString *attributedContent;


@end

NS_ASSUME_NONNULL_END
