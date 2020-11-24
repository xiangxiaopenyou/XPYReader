//
//  XPYChapterModel.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYBaseModel.h"

@class XPYChapterPageModel;

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


#pragma mark - 不保存进数据库
/// 当前章节分页信息
@property (nonatomic, copy) NSArray <XPYChapterPageModel *> *pageModels;


@end

NS_ASSUME_NONNULL_END
